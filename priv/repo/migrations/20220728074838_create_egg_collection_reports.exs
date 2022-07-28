defmodule SmartFarm.Repo.Migrations.CreateEggCollectionReports do
  use Ecto.Migration

  def change do
    create table(:egg_collection_reports) do
      add :comments, :string
      add :good_count, :integer
      add :bad_count, :integer
      add :report_date, :date
      add :bad_count_classification, :jsonb
      add :good_count_classification, :jsonb
      add :report_id, references(:batches_reports, on_delete: :nothing)

      timestamps()
    end

    create index(:egg_collection_reports, [:report_id])
  end
end
