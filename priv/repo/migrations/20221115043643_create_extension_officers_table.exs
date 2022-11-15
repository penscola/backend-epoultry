defmodule SmartFarm.Repo.Migrations.CreateExtensionOfficersTable do
  use Ecto.Migration

  def change do
    create table(:extension_officers, primary_key: false) do
      add :user_id, references(:users), primary_key: true
      add :date_approved, :utc_datetime
      add :address, :jsonb

      timestamps()
    end

    alter table(:users) do
      add :birth_date, :date
      add :gender, :string
      add :national_id, :string
    end

    alter table(:farmers) do
      remove :birth_date, :date
      remove :gender, :string
    end
  end
end
