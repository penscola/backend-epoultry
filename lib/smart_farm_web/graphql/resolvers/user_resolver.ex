defmodule SmartFarmWeb.Resolvers.User do
  use SmartFarm.Shared

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %User{}}
  def get(_args, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def get_user_role(user, _args, %{context: %{current_user: _user}}) do
    {:ok, Accounts.get_user_role(user) |> IO.inspect()}
  end

  @spec register_user(map(), %{context: map()}) :: {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def register_user(args, _context) do
    Accounts.register_user(args.data)
  end

  @spec register_extension_officer(map(), %{context: map()}) ::
          {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def register_extension_officer(args, _context) do
    Accounts.register_extension_officer(args.data)
  end

  @spec register_vet_officer(map(), %{context: map()}) ::
          {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def register_vet_officer(args, _context) do
    Accounts.register_vet_officer(args.data)
  end

  @spec update_user(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def update_user(args, %{context: %{current_user: user}}) do
    Accounts.update_user(user, args.data)
  end

  @spec update_extension_officer(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def update_extension_officer(args, %{context: %{current_user: user}}) do
    Accounts.update_extension_officer(user, args.data)
  end

  @spec update_vet_officer(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def update_vet_officer(args, %{context: %{current_user: user}}) do
    Accounts.update_vet_officer(user, args.data)
  end

  @spec remove_farm_manager(map(), %{context: map()}) ::
          {:ok, true} | {:error, Ecto.Changeset.t()}
  def remove_farm_manager(args, %{context: %{current_user: %User{} = user}}) do
    case Accounts.remove_farm_manager(args.farm_manager_id, args.farm_id, actor: user) do
      {:ok, _result} ->
        {:ok, true}

      other ->
        other
    end
  end

  @spec list_farm_managers(map(), %{context: %{current_user: %User{}}}) :: {:ok, [%User{}, ...]}
  def list_farm_managers(args, %{context: %{current_user: user}}) do
    {:ok, Accounts.list_farm_managers(args, actor: user)}
  end
end
