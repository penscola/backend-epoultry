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
    field :item_type, :item_types_enum

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

  input_object :store_items_filter_input do
    field :farm_id, non_null(:uuid)
    field :item_type, :item_types_enum
    field :bird_type, :bird_type_enum
  end

  object :store_queries do
    field :store_items, list_of(:store_item) do
      arg(:filter, non_null(:store_items_filter_input))

      resolve(&Resolvers.Store.store_items/2)
    end
  end
end
