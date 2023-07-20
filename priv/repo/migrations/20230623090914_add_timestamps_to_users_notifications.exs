defmodule SmartFarm.Repo.Migrations.AddTimestampsToUsersNotifications do
  use Ecto.Migration

  def change do
    alter table(:users_notifications) do
      add :created_at, :naive_datetime
      add :updated_at, :naive_datetime
    end
  end
end
