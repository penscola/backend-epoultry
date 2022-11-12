defmodule SmartFarmWeb.Schema.GroupTypes do
  use SmartFarmWeb, :schema

  object :group do
    field :group_name, :string
    field :group_type, :string
    field :contact_person, :string
    field :phone_number, :string
    field :address, :address

    field :owner, :user do
      resolve(dataloader(Repo))
    end
  end

  input_object :register_group_input do
    field :group_name, :string
    field :group_type, :string
    field :contact_person, :string
    field :phone_number, :string
    field :address, :address_input
    field :password, non_null(:string)
  end

  object :group_auth_mutations do
    field :register_group, non_null(:group) do
      arg(:data, non_null(:register_group_input))

      resolve(&Resolvers.Group.register_group/2)
    end
  end
end
