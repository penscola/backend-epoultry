defmodule SmartFarm.Repo.Migrations.CreateFarmVisitReportTable do
  use Ecto.Migration

  def change do
    create table(:farm_visit_reports) do
      add :farm_information, :jsonb
      add :housing_inspection, :jsonb
      add :store, :jsonb
      add :compound, :jsonb
      add :farm_team, :jsonb
      add :general_observation, :text
      add :recommendations, :text

      add :extension_service_id,
          references(:farm_visit_extension_services, column: :extension_service_id)

      timestamps()
    end
  end
end
