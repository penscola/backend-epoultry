defmodule SmartFarmWeb.Schema.UserTypes do
  use SmartFarmWeb, :schema

  object :user do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string

    field :farmer, :farmer do
      resolve(dataloader(Repo))
    end

    field :owned_farms, list_of(:farm) do
      resolve(dataloader(Repo))
    end

    field :managing_farms, list_of(:farm) do
      resolve(dataloader(Repo))
    end
  end

  object :farmer do
    field :birth_date, :date
    field :gender, :string

    field :user, :user do
      resolve(dataloader(Repo))
    end

    field :owned_farms, :farm do
      resolve(dataloader(Repo))
    end
  end

  input_object :register_user_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :password, non_null(:string)
  end

  input_object :update_user_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :recovery_phone_number, non_null(:string)
  end

  object :user_queries do
    field :user, non_null(:user) do
      resolve(&Resolvers.User.get/2)
    end

    field :farm_managers, list_of(non_null(:user)) do
      resolve(&Resolvers.User.list_farm_managers/2)
    end
  end

  object :user_mutations do
    field :remove_farm_manager, non_null(:boolean) do
      arg(:farm_manager_id, non_null(:uuid))
      arg(:farm_id, non_null(:uuid))

      resolve(&Resolvers.User.remove_farm_manager/2)
    end

    field :update_user, non_null(:user) do
      arg(:data, non_null(:update_user_input))

      resolve(&Resolvers.User.update_user/2)
    end
  end

  object :user_auth_mutations do
    field :register_user, non_null(:user) do
      arg(:data, non_null(:register_user_input))

      resolve(&Resolvers.User.register_user/2)
    end
  end
end
