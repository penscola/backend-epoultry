defmodule SmartFarm.Repo.Migrations.AddAddressToFarms do
  use Ecto.Migration

  def change do
    alter table(:farms) do
      add :address, :jsonb
    end

    alter table(:farmers) do
      modify :birth_date, :date, null: true, from: {:date, null: false}
      modify :gender, :string, null: true, from: {:string, null: false}
    end

    create table(:contractors) do
      add :name, :string, null: false

      timestamps()
    end

    create table(:farms_contractors) do
      add :contractor_id, references(:contractors), null: false
      add :farm_id, references(:farms), null: false

      timestamps()
    end

    create unique_index(:farms_contractors, [:contractor_id, :farm_id])
  end
end
