defmodule SmartFarm.Stores.StoreItem do
  use SmartFarm.Schema

  schema "farms_store_items" do
    field :name, :string
    field :starting_quantity, :float, default: 0.0
    field :measurement_unit, Ecto.Enum, values: [:kilograms, :grams, :litres, :doses]
    field :quantity_used, :float, default: 0.0
    field :quantity_received, :float, default: 0.0
    field :item_type, Ecto.Enum, values: [:medication, :feed, :sawdust, :briquettes]
    belongs_to :farm, Farm
    has_many :restocks, Restock
    has_many :store_reports, StoreItemUsageReport

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :starting_quantity, :measurement_unit, :farm_id])
    |> validate_required([:name, :starting_quantity, :measurement_unit, :farm_id])
    |> unique_constraint([:name, :farm_id])
  end
end
