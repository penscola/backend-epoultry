defmodule SmartFarmWeb.Schema.FarmTypes do
  use SmartFarmWeb, :schema

  object :farm do
    field :id, :uuid
    field :name, :string

    field :owner, :user do
      resolve(dataloader(Repo))
    end

    field :batches, :batch do
      resolve(dataloader(Repo))
    end
  end

  object :farm_queries do
  end

  object :farm_mutations do
  end
end
