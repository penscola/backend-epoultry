defmodule SmartFarm.Repo.Migrations.CreateBirdCountReports do
  use Ecto.Migration

  def change do
    create table(:batches_reports) do
      add :report_date, :date
      add :batch_id, references(:batches, on_delete: :nothing), null: false
      add :reporter_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:batches_reports, [:batch_id])
    create index(:batches_reports, [:reporter_id])

    create table(:bird_count_reports) do
      add :quantity, :integer
      add :reason, :string
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:bird_count_reports, [:report_id])
  end
end
