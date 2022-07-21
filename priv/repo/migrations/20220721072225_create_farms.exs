defmodule SmartFarm.Repo.Migrations.CreateFarms do
  use Ecto.Migration

  def change do
    create table(:farms) do
      add :name, :string, null: false
      add :location, :map
      add :owner_id, references(:farmers, column: :user_id), null: false

      timestamps()
    end

    create index(:farms, [:owner_id])

    create table(:farms_managers) do
      add :user_id, references(:users), null: false
      add :farm_id, references(:farms), null: false

      timestamps()
    end

    create unique_index(:farms_managers, [:user_id, :farm_id])

    create table(:farms_invites) do
      add :farm_id, references(:farms), null: false
      add :receiver_phone_number, :string, null: false
      add :expiry, :utc_datetime, null: false
      add :is_used, :boolean, null: false
      add :receiver_user_id, references(:users)

      timestamps()
    end
  end
end
