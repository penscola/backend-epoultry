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

  def list_farmers(_args, actor: %User{role: :admin}) do
    query =
      from u in User,
        join: f in assoc(u, :owned_farms),
        group_by: u.id,
        order_by: u.first_name,
        select: %{u | owned_farms: coalesce(count(f.id), 0)}

    Repo.all(query)
  end

  def list_extension_officers(args, actor: %User{role: :admin}) do
    base_query =
      from u in User,
        join: e in assoc(u, :extension_officer),
        as: :extension_officer,
        order_by: u.first_name,
        preload: [extension_officer: e]

    args
    |> Enum.reject(fn {_key, val} -> is_nil(val) or val == "" end)
    |> Enum.reduce(base_query, fn
      {:status, "approved"}, base ->
        from [extension_officer: e] in base, where: not is_nil(e.date_approved)

      {:status, "pending"}, base ->
        from [extension_officer: e] in base, where: is_nil(e.date_approved)

      _other, base ->
        base
    end)
    |> Repo.all()
  end

  def list_vet_officers(args, actor: %User{role: :admin}) do
    base_query =
      from u in User,
        join: v in assoc(u, :vet_officer),
        as: :vet_officer,
        order_by: u.first_name,
        preload: [vet_officer: v]

    args
    |> Enum.reject(fn {_key, val} -> is_nil(val) or val == "" end)
    |> Enum.reduce(base_query, fn
      {:status, "approved"}, base ->
        from [vet_officer: v] in base, where: not is_nil(v.date_approved)

      {:status, "pending"}, base ->
        from [vet_officer: v] in base, where: is_nil(v.date_approved)

      _other, base ->
        base
    end)
    |> Repo.all()
  end

  def list_farm_managers(_args, actor: %User{role: :admin}) do
    query =
      from u in User,
        join: f in assoc(u, :managing_farms),
        as: :managing_farms,
        group_by: u.id,
        order_by: u.first_name,
        select: %{u | managing_farms: coalesce(count(f.id), 0)}

    Repo.all(query)
  end

  def list_farm_managers(args, actor: %User{} = user) do
    base_query =
      from u in User,
        join: f in assoc(u, :managing_farms),
        as: :managing_farms,
        on: f.owner_id == ^user.id,
        group_by: u.id

    args
    |> filter_farm_managers(base_query)
    |> Repo.all()
  end

  defp filter_farm_managers(args, base) do
    args
    |> Enum.reject(fn {_key, val} -> is_nil(val) end)
    |> Enum.reduce(base, fn
      {:farm_id, farm_id}, query ->
        from [managing_farms: f] in query, where: f.id == ^farm_id

      _other, query ->
        query
    end)
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

  def get_admin_by_phone_number(number) do
    with {:ok, number} <- User.format_phone_number(number) do
      Repo.get_by(User, phone_number: number, role: :admin)
    end
  end

  def get_user_role(user) do
    user = Repo.preload(user, [:farmer, :vet_officer, :extension_officer])

    case user do
      %{role: :admin} ->
        :admin

      %{vet_officer: %{}} ->
        :vet_officer

      %{extension_officer: %{}} ->
        :extension_officer

      %{farmer: %{}} ->
        :farmer

      _other ->
        :farm_manager
    end
  end

  def verify_admin_credentials(phone, password) do
    phone
    |> get_admin_by_phone_number()
    |> Argon2.check_pass(password)
  end

  def approve_vet_officer(user_id, actor: %User{role: :admin}) do
    case Repo.fetch_by(VetOfficer, user_id: user_id) do
      {:ok, %{date_approved: nil} = vet} ->
        vet
        |> VetOfficer.changeset(%{date_approved: DateTime.utc_now()})
        |> Repo.update()

      {:ok, _vet} ->
        {:error, :already_approved}

      other ->
        other
    end
  end

  def approve_extension_officer(user_id, actor: %User{role: :admin}) do
    case Repo.fetch_by(ExtensionOfficer, user_id: user_id) do
      {:ok, %{date_approved: nil} = extension_officer} ->
        extension_officer
        |> ExtensionOfficer.changeset(%{date_approved: DateTime.utc_now()})
        |> Repo.update()

      {:ok, _officer} ->
        {:error, :already_approved}

      other ->
        other
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
    |> Ecto.Changeset.cast(%{farmer: attrs}, [:phone_number])
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

  def update_extension_officer(%User{} = user, attrs) do
    Multi.new()
    |> Multi.run(:extension_officer, fn _repo, _changes ->
      Repo.fetch_by(ExtensionOfficer, user_id: user.id)
    end)
    |> Multi.update(:user, User.extension_officer_changeset(user, attrs))
    |> Multi.update(:update_officer, fn %{extension_officer: officer} ->
      ExtensionOfficer.changeset(officer, attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _failed_operation, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def update_vet_officer(%User{} = user, attrs) do
    Multi.new()
    |> Multi.run(:vet_officer, fn _repo, _changes ->
      Repo.fetch_by(VetOfficer, user_id: user.id)
    end)
    |> Multi.update(:user, User.vet_officer_changeset(user, attrs))
    |> Multi.update(:update_officer, fn %{vet_officer: officer} ->
      VetOfficer.changeset(officer, attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _failed_operation, changeset, _changes} ->
        {:error, changeset}
    end
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
    |> Multi.run(:user_otp, fn _repo, %{user: user} ->
      create_user_otp(user)
    end)
    |> Multi.run(:send_otp, fn _repo, %{user_otp: user_otp} ->
      case send_otp(user_otp) do
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

  def register_extension_officer(attrs) do
    Multi.new()
    |> Multi.insert(:user, User.extension_officer_registration_changeset(%User{}, attrs))
    |> Multi.run(:user_otp, fn _repo, %{user: user} ->
      create_user_otp(user)
    end)
    |> Multi.run(:send_otp, fn _repo, %{user_otp: user_otp} ->
      case send_otp(user_otp) do
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

  def register_vet_officer(attrs) do
    Multi.new()
    |> Multi.insert(:user, fn _changes ->
      attrs = Map.merge(attrs, %{vet_officer: attrs})
      User.vet_officer_registration_changeset(%User{}, attrs)
    end)
    |> Multi.run(:user_otp, fn _repo, %{user: user} ->
      create_user_otp(user)
    end)
    |> Multi.run(:send_otp, fn _repo, %{user_otp: user_otp} ->
      case send_otp(user_otp) do
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

  def register_group(attrs) do
    Multi.new()
    |> Multi.insert(:user, User.group_registration_changeset(%User{}, attrs))
    |> Multi.insert(:group, fn %{user: user} ->
      Group.changeset(%Group{owner_id: user.id}, attrs)
    end)
    |> Multi.run(:user_otp, fn _repo, %{user: user} ->
      create_user_otp(user)
    end)
    |> Multi.run(:send_otp, fn _repo, %{user_otp: user_otp} ->
      case send_otp(user_otp) do
        {:ok, response} ->
          {:ok, response}

        {:error, response} ->
          {:ok, response}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{group: group}} ->
        {:ok, group}

      {:error, _failed_operation, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def create_user_otp(%User{} = user) do
    %UserOTP{user_id: user.id}
    |> UserOTP.create_changeset(%{phone_number: user.phone_number})
    |> Repo.insert()
  end

  def update_user_otp!(user_otp, changes) do
    user_otp
    |> UserOTP.changeset(changes)
    |> Repo.update!()
  end

  def get_valid_user_otp(phone_number) do
    with {:ok, phone_number} <- User.format_phone_number(phone_number) do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      query =
        from q in UserOTP,
          where: q.expiry > ^now and not q.is_used,
          order_by: [desc: q.expiry],
          limit: 1,
          preload: [:user]

      Repo.fetch_by(query, phone_number: phone_number)
    end
  end

  def request_login_otp(%User{} = user) do
    with {:ok, user_otp} <- create_user_otp(user),
         {:ok, _response} <- send_otp(user_otp) do
      :ok
    end
  end

  def request_login_otp_by_phone(phone_number) do
    with {:ok, user} <- get_user_by_phone_number(phone_number) do
      request_login_otp(user)
    end
  end

  def verify_otp(%UserOTP{} = user_otp, otp_code) do
    case validate_otp(user_otp, otp_code) do
      {:ok, _changes} ->
        update_user_otp!(user_otp, %{attempts: user_otp.attempts + 1, is_used: true})
        :ok

      {:error, _changeset} ->
        user_otp = update_user_otp!(user_otp, %{attempts: user_otp.attempts + 1})
        request_another_login_otp(user_otp)
        {:error, :invalid_otp_code}
    end
  end

  def verify_password(%User{} = user, password) do
    Argon2.check_pass(user, password)
  end

  defp request_another_login_otp(user_otp) do
    user_otp = Repo.preload(user_otp, [:user])

    if user_otp.attempts >= 3 do
      :ok = request_login_otp(user_otp.user)
    end
  end

  defp validate_otp(user_otp, code) do
    user_otp
    |> UserOTP.verify_changeset(%{code: code})
    |> Ecto.Changeset.apply_action(:update)
  end

  defp send_otp(%{code: otp_code} = user_otp) when is_binary(otp_code) do
    if Application.get_env(:smart_farm, :env) == :dev do
      Logger.info("Generated OTP CODE: #{otp_code}")
    end

    message = "Your Verification Code is: #{otp_code}"
    SMS.send(user_otp.phone_number, message)
    {:ok, nil}
  end

  defp send_otp(_other), do: {:error, :missing_code}
end
