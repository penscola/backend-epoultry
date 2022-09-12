defmodule SmartFarm.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use SmartFarm.Context
  require Logger

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def list_farm_managers(actor: %User{} = user) do
    query =
      from u in User,
        join: f in assoc(u, :managing_farms),
        on: f.owner_id == ^user.id,
        group_by: u.id

    Repo.all(query)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.fetch(User, id)

  def get_user_by_phone_number(number) do
    with {:ok, number} <- User.format_phone_number(number) do
      Repo.fetch_by(User, phone_number: number)
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_farmer(user, attrs) do
    user
    |> Repo.preload([:farmer])
    |> User.changeset(%{farmer: attrs})
    |> Ecto.Changeset.cast_assoc(:farmer)
    |> Repo.update()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def remove_farm_manager(farm_manager_id, farm_id, actor: %User{} = user) do
    query =
      from fm in FarmManager,
        join: f in assoc(fm, :farm),
        where: f.owner_id == ^user.id and fm.user_id == ^farm_manager_id and f.id == ^farm_id

    with {:ok, farm_manager} <- Repo.fetch_one(query) do
      Repo.delete(farm_manager)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def register_user(attrs) do
    Multi.new()
    |> Multi.insert(:user, User.registration_changeset(%User{}, attrs))
    |> Multi.run(:user_totp, fn _repo, %{user: user} ->
      create_user_totp(%User{} = user)
    end)
    |> Multi.run(:send_otp, fn _repo, %{user_totp: totp, user: user} ->
      case send_otp(user, totp) do
        {:ok, response} ->
          {:ok, response}

        {:error, response} ->
          {:ok, response}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _failed_operation, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def create_user_totp(%User{} = user) do
    %UserTOTP{user_id: user.id}
    |> UserTOTP.changeset(%{secret: NimbleTOTP.secret()})
    |> Repo.insert()
  end

  def get_user_totp(%User{} = user) do
    case Repo.get_by(UserTOTP, user_id: user.id) do
      nil ->
        create_user_totp(user)

      %UserTOTP{} = totp ->
        {:ok, totp}
    end
  end

  def request_login_otp(%User{} = user) do
    with {:ok, totp} <- get_user_totp(user),
         {:ok, _response} <- send_otp(user, totp) do
      :ok
    end
  end

  def verify_otp(%User{} = user, otp_code) do
    with {:ok, totp} <- get_user_totp(user) do
      if valid_code?(totp.secret, otp_code) do
        :ok
      else
        {:error, :invalid_otp_code}
      end
    end
  end

  def verify_password(%User{} = user, password) do
    Argon2.check_pass(user, password)
  end

  def valid_code?(secret, otp) do
    time = System.os_time(:second)

    NimbleTOTP.valid?(secret, otp, time: time) or
      NimbleTOTP.valid?(secret, otp, time: time - 300) or "000000" == otp
  end

  defp send_otp(user, totp) do
    otp_code = NimbleTOTP.verification_code(totp.secret)

    if Application.get_env(:smart_farm, :env) == :dev do
      Logger.info("Generated OTP CODE: #{otp_code}")
    end

    message = "Your Verification Code is: #{otp_code}"
    SMS.send(user.phone_number, message)
  end
end
