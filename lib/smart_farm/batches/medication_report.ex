defmodule SmartFarm.Batches.MedicationReport do
  use SmartFarm.Schema

  schema "medication_reports" do
    field :quantity, :integer
    field :measurement_unit, Ecto.Enum, values: [:litres], default: :litres
    belongs_to :medication, FarmMedication
    belongs_to :report, Report

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:quantity, :measurement_unit, :medication_id, :report_id])
    |> validate_required([:quantity, :measurement_unit, :medication_id, :report_id])
    |> unique_constraint([:medication_id, :report_id])
  end
end
