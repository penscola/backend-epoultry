defmodule SmartFarm.Reports.StoreItemUsageReport do
  use SmartFarm.Schema

  @feed_types %{
    layers: ["chicken_duck_mash", "growers_mash", "layers_mash"],
    broilers: ["starter_crumbs", "finisher_pellets"],
    kienyeji: ["kienyeji_growers_mash", "chicken_duck_mash"]
  }

  schema "store_items_usage_reports" do
    field :quantity, :float
    field :measurement_unit, Ecto.Enum, values: Ecto.Enum.values(StoreItem, :measurement_unit)
    field :feed_type, :string, virtual: true
    belongs_to :report, Report
    belongs_to :store_item, StoreItem

    timestamps()
  end

  def changeset(%__MODULE__{} = report, %Batch{} = batch, %StoreItem{} = item, attrs) do
    report
    |> cast(attrs, [:store_item_id, :quantity, :measurement_unit, :report_id])
    |> validate_required([:store_item_id, :quantity, :measurement_unit, :report_id])
    |> unique_constraint([:store_item_id, :report_id])
    |> validate_feed_type(batch, item)
  end

  defp validate_feed_type(%{valid?: true} = changeset, batch, %{item_type: :feed} = item) do
    changeset = put_change(changeset, :feed_type, item.name)
    validate_inclusion(changeset, :feed_type, @feed_types[batch.bird_type])
  end

  defp validate_feed_type(changeset, _batch, _item), do: changeset
end
