defmodule SmartFarmWeb.Resolvers.Farm do
  use SmartFarm.Shared

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %Farm{}} | {:error, :not_found}
  def get(%{farm_id: farm_id}, %{context: %{current_user: _user}}) do
    Farms.get_farm(farm_id)
  end

  @spec create_farm(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %Farm{}} | {:error, Ecto.Changeset.t()}
  def create_farm(%{data: data}, %{context: %{current_user: %User{} = user}}) do
    address = Map.take(data, [:latitude, :longitude, :area_name])
    data = Map.merge(data, %{address: address})
    Farms.create_farm(data, actor: user)
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

  @spec join_farm(map(), %{context: %{current_user: %User{}}}) :: {:ok, %Farm{}} | {:error, any()}
  def join_farm(args, %{context: %{current_user: user}}) do
    Farms.join_farm(args.invite_code, user)
  end

  def create_invite(args, %{context: %{current_user: user}}) do
    Farms.create_farm_invite(args.farm_id, actor: user)
  end
end
