defmodule SmartFarm.Repo.Migrations.AddFieldsOnBatchMigration do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      remove :date_schedule
      add :date_scheduled, :date
    end
  end
end
