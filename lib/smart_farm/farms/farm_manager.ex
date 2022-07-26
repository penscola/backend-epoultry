defmodule SmartFarm.Farms.FarmManager do
  use SmartFarm.Schema
  alias SmartFarm.Accounts.User
  alias SmartFarm.Farms.Farm

  schema "farms_managers" do
    belongs_to :farm, Farm
    belongs_to :user, User

    timestamps()
  end
end
