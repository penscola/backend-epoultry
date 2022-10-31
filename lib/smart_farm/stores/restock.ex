defmodule SmartFarm.Stores.Restock do
  use SmartFarm.Schema

  schema "store_items_restocks" do
    field :date_restocked, :date
    field :quantity, :float
    field :measurement_unit, Ecto.Enum, values: Ecto.Enum.values(StoreItem, :measurement_unit)
    belongs_to :store_item, StoreItem

    timestamps()
  end

  def changeset(restock, attrs) do
    restock
    |> cast(attrs, [:date_restocked, :quantity, :measurement_unit, :store_item_id])
    |> validate_required([:date_restocked, :quantity, :measurement_unit, :store_item_id])
  end
end
