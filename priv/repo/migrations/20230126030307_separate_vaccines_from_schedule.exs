defmodule SmartFarm.Repo.Migrations.SeparateVaccinesFromSchedule do
  use Ecto.Migration

  def change do
    rename table("vaccination_schedules"), to: table("vaccinations")

    rename table("batch_vaccinations"), :vaccination_schedule_id, to: :vaccination_id

    alter table(:vaccinations) do
      remove :bird_types, :jsonb
      remove :bird_ages, :jsonb
      add :administration_mode, :string
    end

    create table("vaccination_schedules") do
      add :vaccination_id, references(:vaccinations)
      add :bird_type, :string
      add :bird_ages, :jsonb
      add :repeat_after, :integer

      timestamps()
    end
  end
end
