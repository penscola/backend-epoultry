defmodule SmartFarm.Quotations.Quotation do
  @moduledoc false
  use SmartFarm.Schema

  schema "quotations" do
    field :title, :string
    field :total_cost, :integer

    has_many :items, QuotationItem
    belongs_to :requested_item, QuotationRequestItem
    belongs_to :user, User

    timestamps()
  end

  def changeset(quotation, attrs) do
    quotation
    |> cast(attrs, [:title, :total_cost, :user_id, :requested_item_id])
    |> validate_required([:title])
  end
end
