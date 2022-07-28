defmodule SmartFarm.Repo.Migrations.AddInviteCodeToFarmInvites do
  use Ecto.Migration

  def change do
    alter table(:farms_invites) do
      remove :receiver_phone_number, :string, null: true
      add :invite_code, :string, null: false
    end

    create unique_index(:farms_invites, [:invite_code])
  end
end
