defmodule SmartFarm.Repo.Migrations.CreateFarmInventoryTable do
  use Ecto.Migration

  def change do
    create table(:farms_store_items) do
      add :farm_id, references(:farms, on_delete: :nothing), null: false
      add :name, :string, null: false
      add :starting_quantity, :float, default: 0.0
      add :measurement_unit, :string
      add :quantity_used, :float
      add :quantity_received, :float
      add :item_type, :string

      timestamps()
    end

    create index(:farms_store_items, [:name, :farm_id])

    create table(:store_items_restocks) do
      add :store_item_id, references(:farms_store_items, on_delete: :nothing), null: false
      add :date_restocked, :date
      add :quantity, :float
      add :measurement_unit, :string

      timestamps()
    end

    drop table(:farms_feeds)

    drop table(:medicaton_reports)

    drop table(:farms_medications)

    drop table(:feeds_usage_reports)

    create table(:store_items_usage_reports) do
      add :quantity, :integer, null: false
      add :measurement_unit, :string
      add :store_item_id, references(:farms_store_items, on_delete: :nothing), null: false
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:store_items_usage_reports, [:store_item_id, :report_id])
  end
end
