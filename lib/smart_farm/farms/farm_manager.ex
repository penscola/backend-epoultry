defmodule SmartFarm.Farms.FarmManager do
  use SmartFarm.Schema
  alias SmartFarm.Accounts.User
  alias SmartFarm.Farms.Farm

  schema "farms_managers" do
    belongs_to :farm, Farm, references: :uuid
    belongs_to :user, User, references: :uuid

    timestamps()
  end
end
