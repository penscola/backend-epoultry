defmodule SmartFarm.Repo.Migrations.CreateVaccinationScheduleTables do
  use Ecto.Migration

  def change do
    create table(:vaccination_schedules) do
      add :bird_types, :jsonb
      add :bird_ages, :jsonb
      add :vaccine_name, :string
      add :description, :text

      timestamps()
    end

    create table(:batch_vaccinations) do
      add :batch_id, references(:batches)
      add :vaccination_schedule_id, references(:vaccination_schedules)
      add :date_scheduled, :date
      add :date_completed, :utc_datetime
      add :completer_id, references(:users)

      timestamps()
    end
  end
end
