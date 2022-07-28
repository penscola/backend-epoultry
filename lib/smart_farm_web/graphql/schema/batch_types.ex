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
    :sold
    :mortality
    :curled
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

    field :bird_count_reports, list_of(:bird_count_report) do
      resolve(dataloader(Repo))
    end

    field :current_bird_count, :integer do
      resolve(&Resolvers.Batch.current_bird_count/3)
    end
  end

  object :bird_count_report do
    field :id, :uuid
    field :quantity, :integer
    field :reason, :bird_count_report_reason_enum
    field :report_date, :date
    field :created_at, :datetime

    field :batch, :batch do
      resolve(dataloader(Repo))
    end

    field :reporter, :user do
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

  input_object :create_bird_count_report_input do
    field :quantity, non_null(:integer)
    field :reason, non_null(:bird_count_report_reason_enum)
    field :report_date, :date
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

    field :create_bird_count_report, non_null(:bird_count_report) do
      arg(:data, non_null(:create_bird_count_report_input))
      resolve(&Resolvers.Batch.create_bird_count_report/2)
    end
  end
end
