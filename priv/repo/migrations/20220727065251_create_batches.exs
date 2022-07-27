defmodule SmartFarm.Repo.Migrations.CreateBatches do
  use Ecto.Migration

  def change do
    create table(:batches) do
      add :name, :string, null: false
      add :bird_type, :string
      add :bird_count, :integer
      add :bird_age, :integer
      add :age_type, :string
      add :acquired_date, :date
      add :creator_id, references(:users, on_delete: :nothing)
      add :farm_id, references(:farms, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:batches, [:creator_id])
    create index(:batches, [:farm_id])
  end
end
