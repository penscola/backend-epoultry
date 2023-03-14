defmodule SmartFarmWeb.Schema.UserTypes do
  use SmartFarmWeb, :schema

  enum :user_role_enum do
    value(:admin)
    value(:vet_officer)
    value(:extension_officer)
    value(:farmer)
    value(:farm_manager)
  end

  object :user do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :birth_date, :date
    field :gender, :string
    field :national_id, :string

    field :role, :user_role_enum do
      resolve(&Resolvers.User.get_user_role/3)
    end

    field :farmer, :farmer do
      resolve(dataloader(Repo))
    end

    field :extension_officer, :extension_officer do
      resolve(dataloader(Repo))
    end

    field :vet_officer, :vet_officer do
      resolve(dataloader(Repo))
    end

    field :owned_farms, list_of(:farm) do
      resolve(dataloader(Repo))
    end

    field :managing_farms, list_of(:farm) do
      resolve(dataloader(Repo))
    end

    field :quotations, list_of(:quotation) do
      resolve(dataloader(Repo))
    end

    field :group, :group do
      resolve(dataloader(Repo))
    end

    field :avatar, :file do
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

  object :extension_officer do
    field :user, :user do
      resolve(dataloader(Repo))
    end

    field :date_approved, :eatdatetime
    field :address, :address
  end

  object :vet_officer do
    field :user, :user do
      resolve(dataloader(Repo))
    end

    field :date_approved, :eatdatetime
    field :address, :address
    field :vet_number, :string
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

  input_object :register_extension_officer_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :password, non_null(:string)
    field :national_id, non_null(:string)
  end

  input_object :update_extension_officer_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :recovery_phone_number, :string
    field :address, non_null(:address_input)
  end

  input_object :register_vet_officer_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :password, non_null(:string)
    field :national_id, non_null(:string)
    field :vet_number, non_null(:string)
  end

  input_object :update_vet_officer_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :recovery_phone_number, :string
    field :address, non_null(:address_input)
  end

  object :user_queries do
    field :user, non_null(:user) do
      resolve(&Resolvers.User.get/2)
    end

    field :farm_managers, list_of(non_null(:user)) do
      arg(:farm_id, :uuid)
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

    field :update_extension_officer, non_null(:user) do
      arg(:data, non_null(:update_extension_officer_input))

      resolve(&Resolvers.User.update_extension_officer/2)
    end

    field :update_vet_officer, non_null(:user) do
      arg(:data, non_null(:update_vet_officer_input))

      resolve(&Resolvers.User.update_vet_officer/2)
    end
  end

  object :user_auth_mutations do
    field :register_user, non_null(:user) do
      arg(:data, non_null(:register_user_input))

      resolve(&Resolvers.User.register_user/2)
    end

    field :register_extension_officer, non_null(:user) do
      arg(:data, non_null(:register_extension_officer_input))

      resolve(&Resolvers.User.register_extension_officer/2)
    end

    field :register_vet_officer, non_null(:user) do
      arg(:data, non_null(:register_vet_officer_input))

      resolve(&Resolvers.User.register_vet_officer/2)
    end
  end
end
