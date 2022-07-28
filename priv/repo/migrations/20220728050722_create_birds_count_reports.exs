defmodule SmartFarm.Repo.Migrations.CreateBirdCountReports do
  use Ecto.Migration

  def change do
    create table(:bird_count_reports) do
      add :quantity, :integer
      add :reason, :string
      add :report_date, :date
      add :batch_id, references(:batches, on_delete: :nothing), null: false
      add :reporter_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:bird_count_reports, [:batch_id])
    create index(:bird_count_reports, [:reporter_id])
  end
end
