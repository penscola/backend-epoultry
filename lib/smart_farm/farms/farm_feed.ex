defmodule SmartFarm.Farms.FarmFeed do
  use SmartFarm.Schema

  @feed_types [
    :chicken_duck_mash,
    :growers_mash,
    :layers_mash,
    :starter_crumbs,
    :finisher_pellets,
    :kienyeji_growers_mash
  ]

  schema "farms_feeds" do
    field :name, Ecto.Enum, values: @feed_types
    field :initial_quantity, :integer
    belongs_to :farm, Farm
  end

  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:name, :initial_quantity, :farm_id])
    |> validate_required([:name, :initial_quantity])
  end
end
