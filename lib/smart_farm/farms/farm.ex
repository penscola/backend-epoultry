defmodule SmartFarm.Farms.Farm do
  use SmartFarm.Schema
  import Ecto.Changeset

  alias SmartFarm.Accounts.User

  schema "farms" do
    field :location, :map
    field :name, :string

    belongs_to :owner, User

    timestamps()
  end

  @doc false
  def changeset(farm, attrs) do
    farm
    |> cast(attrs, [:name, :location])
    |> validate_required([:name, :location])
  end
end
