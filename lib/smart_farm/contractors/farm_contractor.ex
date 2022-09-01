defmodule SmartFarm.Contractors.FarmContractor do
  @moduledoc false

  use SmartFarm.Schema

  schema "farms_contractors" do
    belongs_to :farm, Farm
    belongs_to :contractor, Contractor

    timestamps()
  end

  def changeset(contractor, attrs) do
    contractor
    |> cast(attrs, [:farm_id, :contractor_id])
  end
end
