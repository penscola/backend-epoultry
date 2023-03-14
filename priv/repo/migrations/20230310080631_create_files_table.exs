defmodule SmartFarm.Repo.Migrations.CreateFilesTable do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :storage_path, :string, null: false
      add :original_name, :string, null: false
      add :unique_name, :string, null: false
      add :size, :integer, null: false

      timestamps()
    end

    create unique_index(:files, [:storage_path, :unique_name])

    alter table(:users) do
      add :avatar_id, references(:files)
    end

    create table(:extension_service_attachments) do
      add :file_id, references(:files)
      add :extension_service_id, references(:extension_service_requests)
    end
  end
end
