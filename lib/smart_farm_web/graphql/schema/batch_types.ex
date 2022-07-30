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
  end

  enum :bird_count_report_reason_enum do
    value(:sold)
    value(:mortality)
    value(:curled)
    value(:stolen)
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
  end

  object :bird_count_report do
    field :id, :uuid
    field :quantity, :integer
    field :reason, :bird_count_report_reason_enum
  end

  object :bad_count_classification do
    field :fully_broken, :integer
    field :partially_broken, :integer
    field :deformed, :integer
  end

  object :good_count_classification do
    field :medium, :integer
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
    field :bird_counts, non_null(list_of(non_null(:bird_count_report_input)))
    field :egg_collection, non_null(:egg_collection_report_input)
  end

  input_object :bird_count_report_input do
    field :quantity, non_null(:integer)
    field :reason, non_null(:bird_count_report_reason_enum)
  end

  input_object :egg_collection_report_input do
    field :bad_count, non_null(:integer)
    field :comments, :string
    field :good_count, non_null(:integer)
    field :medium_count, non_null(:integer)
    field :large_count, non_null(:integer)
    field :fully_broken, non_null(:integer)
    field :partially_broken, non_null(:integer)
    field :deformed, non_null(:integer)
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
