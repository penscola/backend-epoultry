defmodule SmartFarm.Accounts.Group do
  use SmartFarm.Schema

  schema "groups" do
    field :group_name, :string
    field :group_type, :string
    field :contact_person, :string
    field :phone_number, :string

    embeds_one :address, Address do
      field :county, :string
      field :subcounty, :string
      field :ward, :string
    end

    belongs_to :owner, User

    timestamps()
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:group_name, :group_type, :contact_person, :phone_number, :owner_id])
    |> validate_required([:group_name, :group_type, :contact_person, :phone_number])
    |> cast_embed(:address, with: &address_changeset/2)
  end

  def address_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:county, :subcounty, :ward])
  end
end
