defmodule SmartFarm.Quotations.Cluster do
  @moduledoc false
  use SmartFarm.Schema

  schema "clusters" do
    field :bird_type, Ecto.Enum, values: [:broilers, :layers, :kienyeji]
    field :min_count, :integer
    field :max_count, :integer

    embeds_one :pricing, Pricing do
      field :equipments, :integer
      field :housing, :integer
      field :production, :integer
    end

    timestamps()
  end

  def changeset(cluster, attrs) do
    cluster
    |> cast(attrs, [:bird_type, :min_count, :max_count])
    |> validate_required([:bird_type, :min_count, :max_count])
    |> cast_embed(:pricing, with: &pricing_changeset/2, required: true)
  end

  def pricing_changeset(pricing, attrs) do
    pricing
    |> cast(attrs, [:equipments, :housing, :production])
    |> validate_required([:equipments, :housing, :production])
  end
end
