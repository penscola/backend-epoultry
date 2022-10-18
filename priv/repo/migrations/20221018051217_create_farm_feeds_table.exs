defmodule SmartFarm.Repo.Migrations.CreateFarmFeedsTable do
  use Ecto.Migration

  def change do
    create table(:farms_feeds) do
      add :name, :string, null: false
      add :initial_quantity, :integer
      add :farm_id, references(:farms, on_delete: :nothing), null: false

      timestamps()
    end
  end
end
