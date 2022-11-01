defmodule SmartFarmWeb.Resolvers.Store do
  use SmartFarm.Shared

  @spec store_items(map(), %{context: %{current_user: %User{}}}) :: {:ok, [map(), ...]}
  def store_items(%{filter: filter}, %{context: %{current_user: user}}) do
    Stores.store_items(filter, actor: user)
  end
end
