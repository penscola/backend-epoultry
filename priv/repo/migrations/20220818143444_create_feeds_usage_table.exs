defmodule SmartFarm.Repo.Migrations.CreateFeedsUsageReportsTable do
  use Ecto.Migration

  def change do
    create table(:feeds_usage_reports) do
      add :feed_type, :string, null: false
      add :quantity, :integer, null: false
      add :measurement_unit, :string
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:feeds_usage_reports, [:feed_type, :report_id])
  end
end
