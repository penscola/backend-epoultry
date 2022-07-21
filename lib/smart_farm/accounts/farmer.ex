defmodule SmartFarm.Accounts.Farmer do
  use SmartFarm.Schema
  alias SmartFarm.Accounts.User

  @primary_key false
  schema "farmers" do
    field :birth_date, :date
    field :gender, :string

    belongs_to :user, User, references: :uuid

    timestamps()
  end
end
