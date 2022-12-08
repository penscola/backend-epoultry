defmodule SmartFarm.Quotations.QuotationItem do
  @moduledoc false
  use SmartFarm.Schema

  schema "quotation_items" do
    field :name, :string
    field :quantity, :integer
    field :unit_cost, :integer
    field :total_cost, :integer
    belongs_to :quotation, Quotation

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :unit_cost, :quantity])
    |> validate_required([:name, :unit_cost, :quantity])
    |> put_total_cost()
  end

  defp put_total_cost(%{valid?: true} = changeset) do
    unit_cost = get_field(changeset, :unit_cost)
    quantity = get_field(changeset, :quantity)
    put_change(changeset, :total_cost, quantity * unit_cost)
  end

  defp put_total_cost(changeset), do: changeset
end
