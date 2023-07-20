defmodule SmartFarm.Repo.Migrations.UserNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :title, :string
      add :description, :string
      add :category, :string
      add :priority, :string
      add :action_required, :boolean
      add :action_completed, :boolean
      add :actor_id, references(:users)
      add :target, :jsonb

      timestamps()
    end

    create table(:users_notifications) do
      add :user_id, references(:users)
      add :notification_id, references(:notifications)
      add :read_at, :utc_datetime
    end
  end
end
