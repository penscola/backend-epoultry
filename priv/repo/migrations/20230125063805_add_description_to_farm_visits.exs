defmodule SmartFarm.Repo.Migrations.AddDescriptionToFarmVisits do
  use Ecto.Migration

  def change do
    alter table(:farm_visit_extension_services) do
      add :description, :text
    end
  end
end
