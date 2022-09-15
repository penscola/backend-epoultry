defmodule SmartFarm.Batches.FeedsUsageReport do
  use SmartFarm.Schema

  @feed_types %{
    layers: [:chicken_duck_mash, :growers_mash, :layers_mash],
    broilers: [:starter_crumbs, :finisher_pellets],
    kienyeji: [:kienyeji_growers_mash, :chicken_duck_mash]
  }

  schema "feeds_usage_reports" do
    field :feed_type, Ecto.Enum,
      values: Enum.uniq(@feed_types.layers ++ @feed_types.broilers ++ @feed_types.kienyeji)

    field :quantity, :integer
    field :measurement_unit, Ecto.Enum, values: [:kilograms, :grams], default: :kilograms
    field :bird_type, Ecto.Enum, values: Ecto.Enum.values(Batch, :bird_type), virtual: true
    belongs_to :report, Report

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:feed_type, :quantity, :measurement_unit, :bird_type, :report_id])
    |> validate_required([:feed_type, :quantity, :measurement_unit, :bird_type, :report_id])
    |> unique_constraint([:feed_type, :report_id])
    |> validate_feed_type()
  end

  defp validate_feed_type(%{valid?: true} = changeset) do
    bird_type = get_field(changeset, :bird_type)
    validate_inclusion(changeset, :feed_type, @feed_types[bird_type])
  end

  defp validate_feed_type(changeset), do: changeset
end
