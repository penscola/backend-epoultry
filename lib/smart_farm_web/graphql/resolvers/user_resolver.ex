defmodule SmartFarmWeb.Resolvers.User do
  use SmartFarm.Shared

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %User{}}
  def get(_args, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  @spec register_user(map(), %{context: map()}) :: {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def register_user(args, _context) do
    Accounts.register_user(args.data)
  end

  @spec update_user(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def update_user(args, %{context: %{current_user: user}}) do
    Accounts.update_user(user, args.data)
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
  def list_farm_managers(_args, %{context: %{current_user: user}}) do
    {:ok, Accounts.list_farm_managers(actor: user)}
  end
end
