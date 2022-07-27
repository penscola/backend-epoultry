defmodule SmartFarm.Accounts.User do
  use SmartFarm.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string

    has_one :farmer, Farmer
    has_many :farms, Farm, foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :phone_number])
    |> validate_required([:first_name, :last_name, :phone_number])
    |> unique_constraint(:phone_number)
  end
end
