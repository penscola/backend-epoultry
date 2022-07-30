defmodule SmartFarm.Repo.Migrations.AddUniqueIndexToBatches do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "SELECT true")

    alter table(:batches) do
      modify :name, :citext, null: false, from: {:string, null: false}
    end

    create unique_index(:batches, [:farm_id, :name])
  end
end
