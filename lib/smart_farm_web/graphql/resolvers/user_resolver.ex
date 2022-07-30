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
end
