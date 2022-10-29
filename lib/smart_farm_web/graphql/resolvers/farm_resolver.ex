defmodule SmartFarmWeb.Resolvers.Farm do
  use SmartFarm.Shared
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %Farm{}} | {:error, :not_found}
  def get(%{farm_id: farm_id}, %{context: %{current_user: user}}) do
    Farms.get_farm(farm_id, actor: user)
  end

  @spec create_farm(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %Farm{}} | {:error, Ecto.Changeset.t()}
  def create_farm(%{data: data}, %{context: %{current_user: %User{} = user}}) do
    address = Map.take(data, [:latitude, :longitude, :area_name])
    data = Map.merge(data, %{address: address})
    Farms.create_farm(data, actor: user)
  end

  @spec create_farm_feed(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %FarmFeed{}} | {:error, Ecto.Changeset.t()}
  def create_farm_feed(%{data: data}, %{context: %{current_user: %User{} = user}}) do
    Farms.create_farm_feed(data, actor: user)
  end

  @spec bird_count(%Farm{}, map(), %{context: %{current_user: %User{}}}) ::
          {:ok, integer} | {:error, any}
  def bird_count(farm, _args, %{context: %{current_user: _user}}) do
    {:ok, Farms.get_bird_count(farm)}
  end

  @spec feeds_usage(%Farm{}, map(), %{context: %{current_user: %User{}}}) ::
          {:ok, integer} | {:error, any}
  def feeds_usage(farm, _args, %{context: %{current_user: _user}}) do
    {:ok, Farms.get_feeds_usage(farm)}
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

  @spec batch_by_batches(Absinthe.Resolution.t(), map(), %{context: map()}) ::
          {:ok, map()} | {:error, any}
  def batch_by_batches(farm, _args, %{context: %{current_user: _user}}) do
    batch({Farms, :batch_by_batches, []}, farm.id, fn results ->
      {:ok, Map.get(results, farm.id, [])}
    end)
  end

  @spec list_farm_reports(map(), %{context: %{current_user: %User{}}}) :: {:ok, [map(), ...]}
  def list_farm_reports(%{filter: filter}, %{context: %{current_user: user}}) do
    Farms.list_farm_reports(filter, actor: user)
  end

  @spec get_farm_report(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, map()} | {:error, :not_found}
  def get_farm_report(%{farm_id: farm_id, report_date: report_date}, %{
        context: %{current_user: user}
      }) do
    Farms.get_farm_report(farm_id, report_date, actor: user)
  end
end
