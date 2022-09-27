defmodule SmartFarm.Repo.Migrations.RenameUserTotpsToUserOtps do
  use Ecto.Migration

  def change do
    drop table(:users_totps, prefix: "internal")

    create table(:users_otps, prefix: "internal") do
      add :user_id, references(:users, on_delete: :delete_all, prefix: "public"), null: false
      add :phone_number, :string, null: false
      add :expiry, :utc_datetime, null: false
      add :is_used, :boolean, null: false
      add :code_hash, :text, null: false
      add :attempts, :integer, null: false

      timestamps()
    end

    create index(:users_otps, [:phone_number], prefix: "internal")
  end
end
