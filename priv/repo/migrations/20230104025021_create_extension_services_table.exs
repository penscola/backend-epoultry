defmodule SmartFarm.Repo.Migrations.CreateExtensionServicesTable do
  use Ecto.Migration

  def change do
    create table(:vetinary_officers, primary_key: false) do
      add :user_id, references(:users), primary_key: true
      add :date_approved, :utc_datetime
      add :address, :jsonb
      add :vet_number, :string

      timestamps()
    end

    create table(:extension_service_requests) do
      add :farm_id, references(:farms)
      add :date_accepted, :utc_datetime
      add :date_cancelled, :utc_datetime
      add :acceptor_id, references(:users)
      add :requester_id, references(:users)

      timestamps()
    end

    create table(:farm_visit_extension_services, primary_key: false) do
      add :extension_service_id, references(:extension_service_requests), primary_key: true
      add :visit_date, :date
      add :visit_purpose, :text

      timestamps()
    end

    create table(:medical_visit_extension_services, primary_key: false) do
      add :extension_service_id, references(:extension_service_requests), primary_key: true
      add :bird_type, :string
      add :bird_age, :float
      add :age_type, :string
      add :bird_count, :integer
      add :description, :text

      timestamps()
    end
  end
end
