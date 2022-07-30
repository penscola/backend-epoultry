defmodule SmartFarm.Batches.EggCollectionReport do
  use SmartFarm.Schema

  schema "egg_collection_reports" do
    field :bad_count, :integer
    field :comments, :string
    field :good_count, :integer

    embeds_one :bad_count_classification, BadCount do
      field :fully_broken, :integer, default: 0
      field :partially_broken, :integer, default: 0
      field :deformed, :integer, default: 0
    end

    embeds_one :good_count_classification, GoodCount do
      field :medium, :integer, default: 0
      field :large, :integer, default: 0
    end

    belongs_to :report, Report

    timestamps()
  end

  @doc false
  def changeset(egg_collection_report, attrs) do
    egg_collection_report
    |> cast(attrs, [:comments, :good_count, :bad_count, :report_id])
    |> validate_required([:good_count, :bad_count])
    |> cast_embed(:bad_count_classification, with: &bad_count_changeset/2, required: true)

    # |> cast_embed(:good_count_classification, with: &good_count_changeset/2, required: true)
  end

  def bad_count_changeset(bad_count, attrs) do
    bad_count
    |> cast(attrs, [:fully_broken, :partially_broken, :deformed])
    |> validate_required([:fully_broken, :partially_broken, :deformed])
  end

  def good_count_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:medium, :large])
    |> validate_required([:medium, :large])
  end
end
