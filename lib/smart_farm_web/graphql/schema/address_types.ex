defmodule SmartFarmWeb.Schema.AddressTypes do
  use SmartFarmWeb, :schema

  object :county do
    field :code, :integer
    field :name, :string
    field :subcounties, list_of(:subcounty)
  end

  object :subcounty do
    field :code, :integer
    field :name, :string
    field :wards, list_of(:ward)
  end

  object :ward do
    field :code, :integer
    field :name, :string
  end

  object :address_queries do
    field :counties, non_null(list_of(non_null(:county))) do
      resolve(&Resolvers.Address.counties/2)
    end

    field :county, non_null(:county) do
      arg(:code, non_null(:integer))

      resolve(&Resolvers.Address.get_county/2)
    end

    field :subcounty, non_null(:subcounty) do
      arg(:code, non_null(:integer))

      resolve(&Resolvers.Address.get_subcounty/2)
    end
  end
end
