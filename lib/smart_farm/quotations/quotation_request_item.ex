defmodule SmartFarm.Quotations.QuotationRequestItem do
  @moduledoc false
  use SmartFarm.Schema

  schema "quotation_request_items" do
    field :name, :string
    field :quantity, :integer
    belongs_to :quotation_request, QuotationRequest
    has_one :quotation, Quotation, foreign_key: :requested_item_id

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :quantity])
    |> validate_required([:name, :quantity])
    |> update_change(:name, &String.downcase/1)
  end
end
