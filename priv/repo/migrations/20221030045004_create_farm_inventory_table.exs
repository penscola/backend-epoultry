defmodule SmartFarm.Repo.Migrations.CreateFarmInventoryTable do
  use Ecto.Migration

  def up do
    create table(:farms_store_items) do
      add :farm_id, references(:farms, on_delete: :nothing), null: false
      add :name, :citext, null: false
      add :starting_quantity, :float, default: 0.0
      add :measurement_unit, :string
      add :quantity_used, :float
      add :quantity_received, :float
      add :item_type, :string

      timestamps()
    end

    create unique_index(:farms_store_items, [:name, :farm_id])

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
      add :quantity, :float, null: false
      add :measurement_unit, :string
      add :store_item_id, references(:farms_store_items, on_delete: :nothing), null: false
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:store_items_usage_reports, [:store_item_id, :report_id])

    execute """
    CREATE OR REPLACE FUNCTION update_quantity_used() RETURNS trigger AS $$
    DECLARE
      item_id uuid;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        item_id := OLD.store_item_id;
      ELSE
        item_id := NEW.store_item_id;
      END IF;

      UPDATE farms_store_items 
        SET quantity_used = (SELECT sum(quantity) FROM store_items_usage_reports WHERE store_item_id = item_id) 
        WHERE id = item_id;
      
      RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;
    """

    execute """
    CREATE OR REPLACE FUNCTION update_quantity_received() RETURNS trigger AS $$
    DECLARE
      item_id uuid;
    BEGIN
      IF TG_OP = 'DELETE' THEN
        item_id := OLD.store_item_id;
      ELSE
        item_id := NEW.store_item_id;
      END IF;

      UPDATE farms_store_items 
        SET quantity_received = (SELECT sum(quantity) FROM store_items_restocks WHERE store_item_id = item_id) 
        WHERE id = item_id;
      
      RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER update_quantity_received
      AFTER INSERT OR UPDATE OR DELETE ON store_items_restocks
      FOR EACH ROW
      EXECUTE FUNCTION update_quantity_received();
    """

    execute """
    CREATE TRIGGER update_quantity_used
      AFTER INSERT OR UPDATE OR DELETE ON store_items_usage_reports
      FOR EACH ROW
      EXECUTE FUNCTION update_quantity_used();
    """
  end

  def down do
    drop table(:store_items_usage_reports)

    create table(:feeds_usage_reports) do
      add :feed_type, :string, null: false
      add :quantity, :integer, null: false
      add :measurement_unit, :string
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:feeds_usage_reports, [:feed_type, :report_id])

    create table(:farms_medications) do
      add :name, :string, null: false
      add :initial_quantity, :integer
      add :farm_id, references(:farms, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:farms_medications, [:farm_id, :name])

    create table(:medicaton_reports) do
      add :quantity, :integer, null: false
      add :measurement_unit, :string
      add :medication_id, references(:farms_medications, on_delete: :nothing), null: false
      add :report_id, references(:batches_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:medicaton_reports, [:report_id, :medication_id])

    create table(:farms_feeds) do
      add :name, :string, null: false
      add :initial_quantity, :integer
      add :farm_id, references(:farms, on_delete: :nothing), null: false

      timestamps()
    end

    drop table(:store_items_restocks)

    drop table(:farms_store_items)
  end
end
