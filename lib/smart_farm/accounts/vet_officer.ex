defmodule SmartFarm.Accounts.VetOfficer do
  use SmartFarm.Schema

  @primary_key false
  schema "vetinary_officers" do
    field :date_approved, :utc_datetime
    field :vet_number, :string

    embeds_one :address, Address do
      field :county, :string
      field :subcounty, :string
      field :ward, :string
    end

    belongs_to :user, User, primary_key: true

    timestamps()
  end

  def changeset(officer, attrs) do
    officer
    |> cast(attrs, [:user_id, :date_approved, :vet_number])
    |> validate_required([:vet_number])
    |> cast_embed(:address, with: &address_changeset/2)
  end

  def address_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:county, :subcounty, :ward])
  end
end
