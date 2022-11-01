defmodule SmartFarm.Reports.WeightReport do
  use SmartFarm.Schema

  schema "weight_reports" do
    field :average_weight, :float
    field :measurement_unit, Ecto.Enum, values: [:kilograms, :grams], default: :kilograms
    belongs_to :report, Report

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:average_weight, :measurement_unit, :report_id])
    |> validate_required([:average_weight, :measurement_unit, :report_id])
  end
end
