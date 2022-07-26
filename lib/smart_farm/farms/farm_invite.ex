defmodule SmartFarm.Farms.FarmInvite do
  use SmartFarm.Schema

  alias SmartFarm.Accounts.User
  alias SmartFarm.Farms.Farm

  schema "farms_invites" do
    field :receiver_phone_number, :string
    field :expiry, :utc_datetime
    field :is_used, :boolean

    belongs_to :farm, Farm
    belongs_to :receiver, User, foreign_key: :receiver_user_id

    timestamps()
  end
end
