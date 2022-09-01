defmodule SmartFarm.Contractors.Contractor do
  @moduledoc false

  use SmartFarm.Schema

  schema "contractors" do
    field :name, :string

    timestamps()
  end

  def changeset(contractor, attrs) do
    contractor
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
