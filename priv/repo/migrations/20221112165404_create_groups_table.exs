defmodule SmartFarm.Repo.Migrations.CreateGroupsTable do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :group_name, :string
      add :group_type, :string
      add :address, :jsonb
      add :contact_person, :string
      add :phone_number, :string
      add :owner_id, references(:users)

      timestamps()
    end
  end
end
