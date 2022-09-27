defmodule SmartFarm.Farms.FarmInvite do
  use SmartFarm.Schema
  @expiry_allowance 24 * 3600 * 5

  schema "farms_invites" do
    field :expiry, :utc_datetime, autogenerate: {__MODULE__, :generate_expiry_date, []}
    field :is_used, :boolean, default: false
    field :invite_code, :string, autogenerate: {CodeGenerator, :generate, [4]}

    belongs_to :farm, Farm
    belongs_to :receiver, User, foreign_key: :receiver_user_id

    timestamps()
  end

  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:is_used, :farm_id, :receiver_user_id])
  end

  def generate_expiry_date do
    DateTime.utc_now()
    |> DateTime.add(@expiry_allowance, :second)
    |> DateTime.truncate(:second)
  end
end
