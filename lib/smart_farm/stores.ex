defmodule SmartFarm.Stores do
  @moduledoc false
  use SmartFarm.Context

  @feed_types %{
    layers: ["chicken_duck_mash", "growers_mash", "layers_mash"],
    broilers: ["starter_crumbs", "finisher_pellets"],
    kienyeji: ["kienyeji_growers_mash", "chicken_duck_mash"]
  }

  @spec store_items(map(), actor: nil | %User{}) ::
          {:ok, [%StoreItem{}, ...]} | {:error, :unauthenticated}
  def store_items(_filter, actor: nil), do: {:error, :unauthenticated}

  def store_items(filter, actor: %User{} = user) do
    base_query =
      from s in StoreItem,
        join: f in assoc(s, :farm),
        left_join: m in assoc(f, :managers),
        where: m.id == ^user.id or f.owner_id == ^user.id

    query = filter_store_items(base_query, filter)
    {:ok, Repo.all(query)}
  end

  defp filter_store_items(base, filter) do
    filter
    |> Enum.reject(fn {_key, val} -> is_nil(val) end)
    |> Enum.reduce(base, fn
      {:farm_id, value}, query ->
        from s in query, where: s.farm_id == ^value

      {:item_type, value}, query ->
        from s in query, where: s.item_type == ^value

      {:bird_type, value}, query ->
        from s in query, where: s.item_type == :feed and s.name in ^@feed_types[value]

      _other, query ->
        query
    end)
  end
end
