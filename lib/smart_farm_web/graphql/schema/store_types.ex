defmodule SmartFarmWeb.Schema.StoreTypes do
  use SmartFarmWeb, :schema

  enum :item_types_enum do
    value(:medication)
    value(:feed)
    value(:sawdust)
    value(:briquettes)
  end

  object :store_item do
    field :id, :uuid
    field :name, :string
    field :starting_quantity, :float
    field :quantity_used, :float
    field :quantity_received, :float
    field :measurement_unit, :measurement_unit_enum

    field :restocks, list_of(:restock) do
      resolve(dataloader(Repo))
    end
  end

  object :restock do
    field :id, :uuid
    field :quantity, :float
    field :measurement_unit, :measurement_unit_enum
    field :date_restocked, :date
  end
end
