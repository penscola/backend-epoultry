defmodule SmartFarmWeb.Schema.QuotationTypes do
  use SmartFarmWeb, :schema

  object :quotation do
    field :title, :string
    field :total_cost, :integer
    field :created_at, :datetime

    field :items, list_of(:quotation_item) do
      resolve(dataloader(Repo))
    end
  end

  object :quotation_item do
    field :name, :string
    field :quantity, :integer
    field :unit_cost, :integer
    field :total_cost, :integer

    field :quotation, :quotation do
      resolve(dataloader(Repo))
    end
  end

  object :quotation_request do
    field :created_at, :datetime

    field :items, list_of(:quotation_request_item) do
      resolve(dataloader(Repo))
    end
  end

  object :quotation_request_item do
    field :name, :string
    field :quantity, :integer
  end

  input_object :quotation_request_item_input do
    field :name, :string
    field :quantity, :integer
  end

  input_object :request_quotation_input do
    field :items, non_null(list_of(non_null(:quotation_request_item_input)))
  end

  object :quotation_queries do
  end

  object :quotation_mutations do
    field :request_quotation, non_null(:quotation_request) do
      arg(:data, non_null(:request_quotation_input))

      resolve(&Resolvers.Quotation.request_quotation/2)
    end
  end
end
