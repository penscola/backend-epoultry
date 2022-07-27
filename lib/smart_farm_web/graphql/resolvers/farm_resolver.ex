defmodule SmartFarmWeb.Resolvers.Farm do
  use SmartFarm.Shared

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %Farm{}} | {:error, :not_found}
  def get(%{farm_id: farm_id}, %{context: %{current_user: _user}}) do
    Farms.get_farm(farm_id)
  end
end
