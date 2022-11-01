defmodule SmartFarm.Repo.Migrations.CreateAverageWeightsReportsTable do
  use Ecto.Migration

  def change do
    create table(:weight_reports) do
      add :average_weight, :float, null: false
      add :measurement_unit, :string
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:weight_reports, [:report_id])
  end
end
