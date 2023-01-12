defmodule SmartFarmWeb.Schema.ExtensionServiceTypes do
  use SmartFarmWeb, :schema

  enum :extension_service_status_enum do
    value(:all)
    value(:pending)
    value(:accepted)
    value(:cancelled)
    value(:declined)
  end

  object :extension_service_request do
    field :date_accepted, :eatdatetime
    field :date_cancelled, :eatdatetime
    field :created_at, :eatdatetime
    field :farm_id, :uuid

    field :status, :extension_service_status_enum do
      resolve(&Resolvers.ExtensionService.request_status/3)
    end

    field :farm_visit, :farm_visit do
      resolve(dataloader(Repo))
    end

    field :medical_visit, :medical_visit do
      resolve(dataloader(Repo))
    end

    field :farm, :farm do
      resolve(dataloader(Repo))
    end

    field :acceptor, :user do
      resolve(dataloader(Repo))
    end
  end

  object :farm_visit do
    field :visit_date, :date
    field :visit_purpose, :string
  end

  object :medical_visit do
    field :bird_type, :bird_type_enum
    field :bird_age, :float
    field :age_type, :age_type_enum
    field :bird_count, :integer
  end

  input_object :extension_service_filter_input do
    field :farm_id, :uuid
    field :status, :extension_service_status_enum, default_value: :all
  end

  input_object :request_farm_visit_input do
    field :farm_id, non_null(:uuid)
    field :visit_date, non_null(:date)
    field :visit_purpose, non_null(:string)
  end

  input_object :request_medical_visit_input do
    field :batch_id, non_null(:uuid)
    field :description, non_null(:string)
  end

  object :extension_service_queries do
    field :extension_service_requests, non_null(list_of(non_null(:extension_service_request))) do
      arg(:filter, non_null(:extension_service_filter_input))

      resolve(&Resolvers.ExtensionService.list_extension_service_requests/2)
    end
  end

  object :extension_service_mutations do
    field :request_farm_visit, non_null(:extension_service_request) do
      arg(:data, non_null(:request_farm_visit_input))

      resolve(&Resolvers.ExtensionService.request_farm_visit/2)
    end

    field :request_medical_visit, non_null(:extension_service_request) do
      arg(:data, non_null(:request_medical_visit_input))

      resolve(&Resolvers.ExtensionService.request_medical_visit/2)
    end

    field :accept_extension_request, non_null(:extension_service_request) do
      arg(:extension_service_id, non_null(:uuid))

      resolve(&Resolvers.ExtensionService.accept_extension_request/2)
    end

    field :cancel_extension_request, non_null(:extension_service_request) do
      arg(:extension_service_id, non_null(:uuid))

      resolve(&Resolvers.ExtensionService.cancel_extension_request/2)
    end
  end
end
