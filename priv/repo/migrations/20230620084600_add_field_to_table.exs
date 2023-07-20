defmodule SmartFarm.Repo.Migrations.AddFieldToTable do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :name, :string
      add :date_scheduled, :date
    end
  end
end
