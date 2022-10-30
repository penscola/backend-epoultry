defmodule SmartFarm.Stores.StoreItem do
  use SmartFarm.Schema

  schema "farms_store_items" do
    field :name, :string
    field :starting_quantity, :float, default: 0.0
    field :measurement_unit, Ecto.Enum, values: [:kilograms, :grams, :litres]
    field :quantity_used, :float
    field :quantity_received, :float
    field :item_type, Ecto.Enum, values: [:medication, :feed, :other]
    belongs_to :farm, Farm

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :starting_quantity, :measurement_unit, :farm_id])
    |> validate_required([:name, :starting_quantity, :measurement_unit, :farm_id])
    |> unique_constraint([:name, :farm_id])
  end
end
