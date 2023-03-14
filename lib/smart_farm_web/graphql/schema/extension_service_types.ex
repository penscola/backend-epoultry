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
    field :id, :uuid
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

    field :farm_visit_report, :farm_visit_report do
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

    field :attachments, list_of(:file) do
      resolve(dataloader(Repo))
    end
  end

  object :farm_visit do
    field :visit_date, :date
    field :visit_purpose, :string
    field :description, :string

    field :report, :farm_visit_report do
      resolve(dataloader(Repo))
    end
  end

  object :medical_visit do
    field :bird_type, :bird_type_enum
    field :bird_age, :float
    field :age_type, :age_type_enum
    field :bird_count, :integer
    field :description, :string
  end

  object :farm_visit_report do
    field :id, :uuid
    field :general_observation, :string
    field :recommendations, :string
    field :farm_information, :farm_information_report
    field :housing_inspection, :housing_inspection_report
    field :store, :store_report
    field :compound, :compound_report
    field :farm_team, :farm_team_report
  end

  object :farm_information_report do
    field :farm_officer_contact, :string
    field :farm_assistant_contact, :string
    field :age_type, :age_type_enum
    field :bird_age, :integer
    field :bird_type, :bird_type_enum
    field :remaining_bird_count, :integer
    field :mortality, :integer
    field :delivered_bird_count, :integer
  end

  object :housing_inspection_report do
    field :bio_security, :string
    field :cobwebs, :string
    field :dust, :string
    field :lighting, :string
    field :ventilation, :string
    field :repair_and_maintainance, :string
    field :drinkers, :string
    field :feeders, :string
  end

  object :store_report do
    field :stock_take, :string
    field :arrangement, :string
    field :cleanliness, :string
  end

  object :compound_report do
    field :landscape, :string
    field :security, :string
    field :tank_cleanliness, :string
  end

  object :farm_team_report do
    field :cleanliness, :string
    field :uniforms, :string
    field :gumboots, :string
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
    field :attachments, list_of(non_null(:upload))
  end

  input_object :create_farm_visit_report_input do
    field :extension_service_id, non_null(:uuid)
    field :general_observation, :string
    field :recommendations, :string
    field :farm_information, :farm_information_report_input
    field :housing_inspection, :housing_inspection_report_input
    field :store, :store_report_input
    field :compound, :compound_report_input
    field :farm_team, :farm_team_report_input
  end

  input_object :farm_information_report_input do
    import_fields(:farm_information_report)
  end

  input_object :housing_inspection_report_input do
    import_fields(:housing_inspection_report)
  end

  input_object :store_report_input do
    import_fields(:store_report)
  end

  input_object :compound_report_input do
    import_fields(:compound_report)
  end

  input_object :farm_team_report_input do
    import_fields(:farm_team_report)
  end

  object :extension_service_queries do
    field :extension_service_requests, non_null(list_of(non_null(:extension_service_request))) do
      arg(:filter, non_null(:extension_service_filter_input))

      resolve(&Resolvers.ExtensionService.list_extension_service_requests/2)
    end

    field :extension_service_request, non_null(:extension_service_request) do
      arg(:extension_service_id, non_null(:uuid))

      resolve(&Resolvers.ExtensionService.get_extension_service_request/2)
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

    field :create_farm_visit_report, non_null(:farm_visit_report) do
      arg(:data, non_null(:create_farm_visit_report_input))

      resolve(&Resolvers.ExtensionService.create_farm_visit_report/2)
    end
  end
end
