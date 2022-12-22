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
    |> maybe_skip_insertion()
  end

  defp maybe_skip_insertion(changeset) do
    if changeset.valid? and get_change(changeset, :quantity) == 0 do
      %{changeset | action: :ignore}
    else
      changeset
    end
  end
end
