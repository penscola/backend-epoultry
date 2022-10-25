defmodule SmartFarm.Factory do
  use ExMachina.Ecto, repo: SmartFarm.Repo
  use SmartFarm.Shared

  def user_factory do
    %User{
      first_name: "John",
      last_name: "Doe",
      phone_number: sequence(:phone_number, &"07#{&1}", start_at: 10_000_000)
    }
  end

  def quotation_request_factory do
    %QuotationRequest{items: build_list(3, :quotation_request_item)}
  end

  def quotation_request_item_factory do
    %QuotationRequestItem{
      name: sequence(:bird_type, [:broilers, :layers, :kienyeji]),
      quantity: 100
    }
  end

  def cluster_factory do
    %Cluster{
      bird_type: sequence(:bird_type, [:broilers, :layers, :kienyeji]),
      min_count: 0,
      max_count: 300,
      pricing: %Cluster.Pricing{equipments: 10000, housing: 40000, production: 30000}
    }
  end
end
