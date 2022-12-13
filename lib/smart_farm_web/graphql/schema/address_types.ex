defmodule SmartFarmWeb.Schema.AddressTypes do
  use SmartFarmWeb, :schema

  object :county do
    field :name, :string
    field :subcounties, list_of(:subcounty)
  end

  object :subcounty do
    field :name, :string
    field :wards, list_of(:ward)
  end

  object :ward do
    field :name, :string
  end

  object :address_queries do
    field :counties, non_null(list_of(non_null(:county))) do
      resolve(&Resolvers.Address.counties/2)
    end
  end
end
