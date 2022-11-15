defmodule SmartFarm.Accounts.Farmer do
  use SmartFarm.Schema
  alias SmartFarm.Accounts.User

  @primary_key false
  schema "farmers" do
    belongs_to :user, User
    has_many :farms, Farm, foreign_key: :owner_id, references: :user_id

    timestamps()
  end

  def changeset(farmer, attrs) do
    farmer
    |> cast(attrs, [:user_id])
  end
end
