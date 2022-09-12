defmodule SmartFarm.Quotations.QuotationRequest do
  @moduledoc false
  use SmartFarm.Schema

  schema "quotation_requests" do
    belongs_to :user, User
    has_many :items, QuotationRequestItem

    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:user_id])
    |> cast_assoc(:items, required: true)
  end
end
