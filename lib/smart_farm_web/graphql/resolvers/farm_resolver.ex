defmodule SmartFarmWeb.Resolvers.Farm do
  use SmartFarm.Shared

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %Farm{}} | {:error, :not_found}
  def get(%{farm_id: farm_id}, %{context: %{current_user: _user}}) do
    Farms.get_farm(farm_id)
  end

  @spec bird_count(%Farm{}, map(), %{context: %{current_user: %User{}}}) ::
          {:ok, integer} | {:error, any}
  def bird_count(farm, _args, %{context: %{current_user: _user}}) do
    {:ok, Farms.get_bird_count(farm)}
  end

  @spec egg_count(%Farm{}, map(), %{context: %{current_user: %User{}}}) ::
          {:ok, integer} | {:error, any}
  def egg_count(farm, _args, %{context: %{current_user: _user}}) do
    {:ok, Farms.get_egg_count(farm)}
  end
end
