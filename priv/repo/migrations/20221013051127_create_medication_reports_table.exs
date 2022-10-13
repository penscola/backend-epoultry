defmodule SmartFarm.Repo.Migrations.CreateMedicationReportsTable do
  use Ecto.Migration

  def change do
    create table(:farms_medications) do
      add :name, :string, null: false
      add :initial_quantity, :integer
      add :farm_id, references(:farms, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:farms_medications, [:farm_id, :name])

    create table(:medicaton_reports) do
      add :quantity, :integer, null: false
      add :measurement_unit, :string
      add :medication_id, references(:farms_medications, on_delete: :nothing), null: false
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:medicaton_reports, [:report_id, :medication_id])
  end
end
