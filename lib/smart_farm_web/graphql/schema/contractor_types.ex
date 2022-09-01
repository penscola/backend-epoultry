defmodule SmartFarmWeb.Schema.ContractorTypes do
  use SmartFarmWeb, :schema

  object :contractor do
    field :id, :uuid
    field :name, :string
  end

  object :contractor_queries do
    field :contractors, list_of(:contractor) do
      resolve(&Resolvers.Contractor.list/2)
    end

    field :contractor, non_null(:contractor) do
      arg(:contractor_id, non_null(:uuid))

      resolve(&Resolvers.Contractor.get/2)
    end
  end

  object :contractor_mutations do
  end
end
