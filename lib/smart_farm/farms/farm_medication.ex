defmodule SmartFarm.Farms.FarmMedication do
  use SmartFarm.Schema

  schema "farms_medications" do
    field :name, :string
    field :initial_quantity, :integer
    belongs_to :farm, Farm

    timestamps()
  end

  def changeset(medication, attrs) do
    medication
    |> cast(attrs, [:name, :initial_quantity, :farm_id])
    |> validate_required([:name, :initial_quantity, :farm_id])
    |> unique_constraint([:name, :farm_id])
  end
end
