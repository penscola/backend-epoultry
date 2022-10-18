defmodule SmartFarmWeb.Schema.BatchTypes do
  use SmartFarmWeb, :schema

  enum :age_type_enum do
    value(:weeks)
    value(:days)
    value(:months)
  end

  enum :bird_type_enum do
    value(:broilers)
    value(:layers)
    value(:kienyeji)
  end

  enum :bird_count_report_reason_enum do
    value(:sold)
    value(:mortality)
    value(:curled)
    value(:stolen)
  end

  enum :measurement_unit_enum do
    value(:kilograms)
    value(:grams)
  end

  enum :medication_measurement_unit_enum do
    value(:litres)
  end

  enum :feed_types_enum do
    value(:layers_mash)
    value(:chicken_duck_mash)
    value(:growers_mash)
    value(:starter_crumbs)
    value(:finisher_pellets)
    value(:kienyeji_growers_mash)
  end

  object :batch do
    field :id, :uuid
    field :acquired_date, :date
    field :age_type, :age_type_enum

    field :bird_age, :integer do
      "age of birds when batch was acqquired"
    end

    field :bird_count, :integer do
      description("original bird count when the batch was acquired")
    end

    field :bird_type, :bird_type_enum
    field :name, :string
    field :created_at, :datetime
    field :todays_submission, :boolean

    field :reports, list_of(:batch_report) do
      resolve(dataloader(Repo))
    end
  end

  object :batch_report do
    field :id, :uuid
    field :report_date, :date

    field :bird_counts, list_of(:bird_count_report) do
      resolve(dataloader(Repo))
    end

    field :egg_collection, :egg_collection_report do
      resolve(dataloader(Repo))
    end

    field :medications, list_of(:medication_report) do
      resolve(dataloader(Repo))
    end
  end

  object :bird_count_report do
    field :id, :uuid
    field :quantity, :integer
    field :reason, :bird_count_report_reason_enum
    field :selling_price, :integer
  end

  object :bad_count_classification do
    field :broken, :integer
    field :deformed, :integer
  end

  object :good_count_classification do
    field :small, :integer
    field :large, :integer
  end

  object :egg_collection_report do
    field :id, :uuid
    field :bad_count, :integer
    field :comments, :string
    field :good_count, :integer
    field :bad_count_classification, :bad_count_classification
    field :good_count_classification, :good_count_classification
  end

  object :feeds_usage_report do
    field :id, :uuid
    field :feed_type, :feed_types_enum
    field :quantity, :integer
    field :measurement_unit, :measurement_unit_enum
  end

  object :medication_report do
    field :id, :uuid
    field :quantity, :integer
    field :measurement_unit, :medication_measurement_unit_enum

    field :medication, :farm_medication do
      resolve(dataloader(Repo))
    end
  end

  input_object :create_batch_input do
    field :acquired_date, non_null(:date)
    field :age_type, non_null(:age_type_enum)
    field :bird_age, non_null(:integer)
    field :bird_count, non_null(:integer)
    field :bird_type, non_null(:bird_type_enum)
    field :name, non_null(:string)
    field :farm_id, non_null(:uuid)
  end

  input_object :create_batch_report_input do
    field :report_date, :date, description: "defaults to the current date"
    field :batch_id, non_null(:uuid)
    field :bird_counts, list_of(non_null(:bird_count_report_input))
    field :egg_collection, :egg_collection_report_input
    field :feeds_usage_reports, non_null(list_of(non_null(:feeds_usage_report_input)))
    field :medications, list_of(non_null(:medication_report_input))
  end

  input_object :bird_count_report_input do
    field :quantity, non_null(:integer)
    field :reason, non_null(:bird_count_report_reason_enum)
    field :selling_price, :integer
  end

  input_object :egg_collection_report_input do
    field :comments, :string
    field :egg_count, non_null(:integer)
    field :small_count, :integer
    field :large_count, :integer
    field :broken_count, non_null(:integer)
    field :deformed_count, :integer, default_value: 0
  end

  input_object :feeds_usage_report_input do
    field :feed_type, non_null(:feed_types_enum)
    field :quantity, non_null(:integer)
    field :measurement_unit, :measurement_unit_enum, default_value: :kilograms
  end

  input_object :medication_report_input do
    field :medication_id, non_null(:uuid)
    field :quantity, non_null(:integer)
    field :measurement_unit, :medication_measurement_unit_enum, default_value: :litres
  end

  object :batch_queries do
    field :batch, non_null(:batch) do
      arg(:batch_id, non_null(:uuid))
      resolve(&Resolvers.Batch.get_batch/2)
    end
  end

  object :batch_mutations do
    field :create_batch, non_null(:batch) do
      arg(:data, non_null(:create_batch_input))
      resolve(&Resolvers.Batch.create_batch/2)
    end

    field :create_batch_report, non_null(:batch_report) do
      arg(:data, non_null(:create_batch_report_input))
      resolve(&Resolvers.Batch.create_batch_report/2)
    end
  end
end
