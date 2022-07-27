defmodule SmartFarm.Farms.Farm do
  use SmartFarm.Schema

  schema "farms" do
    field :location, :map
    field :name, :string

    belongs_to :owner, User
    has_many :batches, Batch
    many_to_many :managers, User, join_through: FarmManager

    timestamps()
  end

  @doc false
  def changeset(farm, attrs) do
    farm
    |> cast(attrs, [:name, :location])
    |> validate_required([:name, :location])
  end
end
