defmodule SmartFarm.Farms.FarmManager do
  use SmartFarm.Schema
  alias SmartFarm.Accounts.User
  alias SmartFarm.Farms.Farm

  schema "farms_managers" do
    belongs_to :farm, Farm
    belongs_to :user, User

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:farm_id, :user_id])
    |> unique_constraint([:farm_id, :user_id])
  end
end
