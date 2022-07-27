defmodule SmartFarmWeb.Schema.BatchTypes do
  use SmartFarmWeb, :schema

  enum :age_type_enum do
    value(:weeks)
    value(:days)
    value(:months)
  end

  object :batch do
    field :id, :uuid
    field :acquired_date, :date
    field :age_type, :age_type_enum
    field :bird_age, :integer
    field :bird_count, :integer
    field :bird_type, :string
    field :name, :string
    field :created_at, :datetime
  end

  input_object :create_batch_input do
    field :acquired_date, non_null(:date)
    field :age_type, non_null(:age_type_enum)
    field :bird_age, non_null(:integer)
    field :bird_count, non_null(:integer)
    field :bird_type, non_null(:string)
    field :name, non_null(:string)
    field :farm_id, non_null(:uuid)
  end

  object :batch_queries do
    field :batch, non_null(:batch) do
      arg(:batch_id, non_null(:uuid))
      resolve(&Resolvers.Batch.get/2)
    end
  end

  object :batch_mutations do
    field :create_batch, non_null(:batch) do
      arg(:data, non_null(:create_batch_input))
      resolve(&Resolvers.Batch.create/2)
    end
  end
end
