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

  def get_user_by_phone_number(number) do
    Repo.fetch_by(User, phone_number: number)
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def create_user_totp(%User{} = user) do
    %UserTOTP{user_id: user.id}
    |> UserTOTP.changeset(%{secret: NimbleTOTP.secret()})
    |> Repo.insert()
  end

  def get_user_otp(%User{} = user) do
    case Repo.get_by(UserTOTP, user_id: user.id) do
      nil ->
        create_user_totp(user)

      %UserTOTP{} = totp ->
        {:ok, totp}
    end
  end

  def request_login_otp(%User{} = user) do
    with {:ok, totp} <- get_user_otp(user),
         {:ok, _response} <- send_otp(user, totp) do
      :ok
    end
  end

  def verify_otp(%User{} = user, otp_code) do
    with {:ok, totp} <- get_user_otp(user) do
      if valid_code?(totp.secret, otp_code) do
        :ok
      else
        {:error, :invalid_otp_code}
      end
    end
  end

  def valid_code?(secret, otp) do
    time = System.os_time(:second)

    NimbleTOTP.valid?(secret, otp, time: time) or
      NimbleTOTP.valid?(secret, otp, time: time - 60 * 10)
  end

  defp send_otp(user, totp) do
    otp_code = NimbleTOTP.verification_code(totp.secret)

    if Application.get_env(:smart_farm, :env) == :dev do
      Logger.info("Generated OTP CODE: #{otp_code}")
    end

    SMS.send(user.phone_number, otp_code)
  end
end
