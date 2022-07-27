defmodule SmartFarmWeb.Resolvers.User do
  use SmartFarm.Shared

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %User{}}
  def get(_args, %{context: %{current_user: user}}) do
    {:ok, user}
  end
end
