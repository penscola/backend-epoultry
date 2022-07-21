defmodule SmartFarm.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :phone_number, :string
      add :alternative_phone_number, :string

      timestamps()
    end

    create unique_index(:users, [:phone_number])

    create table(:farmers, primary_key: false) do
      add :user_id, references(:users), primary_key: true
      add :birth_date, :date, null: false
      add :gender, :string, null: false

      timestamps()
    end

    execute("CREATE SCHEMA IF NOT EXISTS internal", "DROP SCHEMA IF EXISTS internal")

    create table(:users_totps, prefix: "internal") do
      add :user_id, references(:users, on_delete: :delete_all, prefix: "public"), null: false
      add :secret, :binary

      timestamps()
    end

    create unique_index(:users_totps, [:user_id], prefix: "internal")
  end
end
