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
    # value(:grams)
    value(:litres)
  end

  enum :medication_measurement_unit_enum do
    value(:litres)
    value :doses
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
    field :created_at, :eatdatetime
    field :todays_submission, :boolean

    field :reports, list_of(:batch_report) do
      resolve(dataloader(Repo))
    end

    field :farm, :farm do
      resolve(dataloader(Repo))
    end
  end

  object :batch_report do
    field :id, :uuid
    field :report_date, :date

    field :batch, :batch do
      resolve(dataloader(Repo))
    end

    field :bird_counts, list_of(:bird_count_report) do
      resolve(dataloader(Repo))
    end

    field :egg_collection, :egg_collection_report do
      resolve(dataloader(Repo))
    end

    field :store_reports, list_of(:store_item_report) do
      resolve(dataloader(Repo))
    end

    field :weight_report, :weight_report do
      resolve(dataloader(Repo))
    end

    field :reporter, :user do
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

  object :store_item_report do
    field :id, :uuid
    field :quantity, :float
    field :measurement_unit, :measurement_unit_enum

    field :store_item, :store_item do
      resolve(dataloader(Repo))
    end
  end

  object :weight_report do
    field :average_weight, :float
    field :measurement_unit, :measurement_unit_enum
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
    field :feeds_report, non_null(:feeds_report)
    field :medications_report, :medications_report
    field :sawdust_report, :sawdust_report
    field :briquettes_report, :briquettes_report
    field :weight_report, :weight_report_input
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

  input_object :feeds_report do
    field :used, non_null(list_of(non_null(:feeds_report_input)))
    field :in_store, list_of(non_null(:feeds_report_input))
    field :received, list_of(non_null(:feeds_report_input))
  end

  input_object :feeds_report_input do
    field :feed_type, non_null(:feed_types_enum)
    field :quantity, non_null(:float)
    field :measurement_unit, :measurement_unit_enum, default_value: :kilograms
  end

  input_object :medications_report do
    field :used, list_of(non_null(:medication_report_input))
    field :in_store, list_of(non_null(:medication_report_input))
    field :received, list_of(non_null(:medication_report_input))
  end

  input_object :medication_report_input do
    field :name, non_null(:string)
    field :quantity, non_null(:float)
    field :measurement_unit, :medication_measurement_unit_enum, default_value: :litres
  end

  input_object :sawdust_report do
    field :used, :sawdust_report_input
    field :in_store, :sawdust_report_input
    field :received, :sawdust_report_input
  end

  input_object :sawdust_report_input do
    field :quantity, non_null(:float)
    field :measurement_unit, :measurement_unit_enum, default_value: :kilograms
  end

  input_object :briquettes_report do
    field :used, :briquettes_report_input
    field :in_store, :briquettes_report_input
    field :received, :briquettes_report_input
  end

  input_object :briquettes_report_input do
    field :quantity, non_null(:float)
    field :measurement_unit, :measurement_unit_enum, default_value: :kilograms
  end

  input_object :weight_report_input do
    field :measurement_unit, :measurement_unit_enum, default_value: :kilograms
    field :average_weight, non_null(:float)
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
