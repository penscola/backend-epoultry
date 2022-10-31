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

    field :feeds_usage, :float do
      resolve(&Resolvers.Farm.feeds_usage/3)
    end

    field :feeds_remaining, :float do
      resolve(&Resolvers.Farm.feeds_remaining/3)
    end

    field :owner, :user do
      resolve(dataloader(Repo))
    end

    field :medications, list_of(:farm_medication) do
      resolve(dataloader(Repo))
    end

    field :feeds, list_of(:farm_feed) do
      resolve(dataloader(Repo))
    end

    field :contractor, :contractor do
      resolve(dataloader(Repo))
    end

    field :batches, list_of(:batch) do
      resolve(&Resolvers.Farm.batch_by_batches/3)
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

  object :farm_medication do
    field :id, :uuid
    field :name, :string
    field :initial_quantity, :integer
  end

  object :farm_feed do
    field :id, :uuid
    field :name, :feed_types_enum
    field :initial_quantity, :integer
  end

  object :farm_report do
    field :report_date, :date
    field :farm_id, :uuid

    field :bird_counts, list_of(:farm_bird_count_report),
      description: "only loaded for getFarmReport"

    field :feeds_usage, list_of(:farm_feed_usage_report),
      description: "only loaded for getFarmReport"

    field :egg_collection, :farm_egg_collection_report,
      description: "only loaded for getFarmReport"
  end

  object :farm_bird_count_report do
    field :bird_type, :bird_type_enum
    field :current_quantity, :integer
    field :reports, list_of(:batch_report)
    field :reasons, non_null(list_of(non_null(:bird_count_reason)))
  end

  object :bird_count_reason do
    field :reason, :bird_count_report_reason_enum
    field :quantity, :integer
  end

  object :farm_feed_usage_report do
    field :feed_type, :feed_types_enum
    field :current_quantity, :float
    field :used_quantity, :float
    field :reports, list_of(:batch_report)
  end

  object :farm_egg_collection_report do
    field :good_count, :integer
    field :deformed_count, :integer
    field :broken_count, :integer
    field :reports, list_of(:batch_report)
  end

  input_object :create_farm_input do
    field :name, non_null(:string)
    field :area_name, :string
    field :latitude, :float
    field :longitude, :float
    field :contractor_id, :uuid
  end

  input_object :create_farm_feed_input do
    field :name, non_null(:feed_types_enum)
    field :initial_quantity, non_null(:integer)
    field :farm_id, non_null(:uuid)
  end

  input_object :farm_reports_filter_input do
    field :farm_id, non_null(:uuid)
    field :start_date, :date
    field :end_date, :date
    field :limit, :integer, default_value: 10
    field :name, :string
  end

  object :farm_queries do
    field :get_farm, non_null(:farm) do
      arg(:farm_id, non_null(:uuid))

      resolve(&Resolvers.Farm.get/2)
    end

    field :farm_reports, list_of(non_null(:farm_report)) do
      arg(:filter, non_null(:farm_reports_filter_input))

      resolve(&Resolvers.Farm.list_farm_reports/2)
    end

    field :get_farm_report, non_null(:farm_report) do
      arg(:farm_id, non_null(:uuid))
      arg(:report_date, non_null(:date))

      resolve(&Resolvers.Farm.get_farm_report/2)
    end
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

    field :create_farm_feed, non_null(:farm_feed) do
      arg(:data, non_null(:create_farm_feed_input))

      resolve(&Resolvers.Farm.create_farm_feed/2)
    end
  end
end
