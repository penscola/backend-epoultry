defmodule SmartFarmWeb.Schema.FarmTypes do
  use SmartFarmWeb, :schema

  object :farm do
    field :id, :uuid
    field :name, :string
    field :address, :farm_address

    field :bird_count, :integer do
      resolve(&Resolvers.Farm.bird_count/3)
    end

    field :egg_count, :integer do
      resolve(&Resolvers.Farm.egg_count/3)
    end

    field :owner, :user do
      resolve(dataloader(Repo))
    end

    # field :contractor, :contractor do
    #   resolve(dataloader(Repo))
    # end

    field :batches, list_of(:batch) do
      resolve(dataloader(Repo))
    end
  end

  object :farm_address do
    field :latitude, :float
    field :longitude, :float
    field :region, :string
    field :area_name, :string
    field :directions, :string
  end

  object :invite do
    field :invite_code, :string
    field :expiry, :datetime
  end

  input_object :create_farm_input do
    field :name, non_null(:string)
    field :area_name, :string
    field :latitude, :float
    field :longitude, :float
    field :contractor_id, :uuid
  end

  object :farm_queries do
  end

  object :farm_mutations do
    field :join_farm, non_null(:farm) do
      arg(:invite_code, non_null(:string))

      resolve(&Resolvers.Farm.join_farm/2)
    end

    field :create_invite, non_null(:invite) do
      arg(:farm_id, non_null(:uuid))

      resolve(&Resolvers.Farm.create_invite/2)
    end

    field :create_farm, non_null(:farm) do
      arg(:data, non_null(:create_farm_input))

      resolve(&Resolvers.Farm.create_farm/2)
    end
  end
end
