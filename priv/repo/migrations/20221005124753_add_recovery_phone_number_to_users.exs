defmodule SmartFarm.Repo.Migrations.AddRecoveryPhoneNumberToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :recovery_phone_number, :string
    end
  end
end
