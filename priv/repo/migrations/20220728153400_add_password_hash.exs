defmodule SmartFarm.Repo.Migrations.AddPasswordHash do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :string
    end

    create unique_index(:batches_reports, [:report_date, :batch_id])
  end
end
