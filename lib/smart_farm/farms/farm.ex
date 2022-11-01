defmodule SmartFarm.Farms.Farm do
  use SmartFarm.Schema

  schema "farms" do
    field :name, :string

    embeds_one :address, Address do
      field :latitude, :float
      field :longitude, :float
      field :region, :string
      field :area_name, :string
      field :directions, :string
    end

    belongs_to :owner, User
    has_one :farm_contractor, FarmContractor
    has_one :contractor, through: [:farm_contractor, :contractor]
    has_many :batches, Batch
    has_many :store_items, StoreItem
    many_to_many :managers, User, join_through: FarmManager

    timestamps()
  end

  @doc false
  def changeset(farm, attrs) do
    farm
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_embed(:address, with: &address_changeset/2)
  end

  def address_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:latitude, :longitude, :directions, :region, :area_name])
  end
end
