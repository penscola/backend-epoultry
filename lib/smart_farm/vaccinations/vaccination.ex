defmodule SmartFarm.Vaccinations.Vaccination do
  use SmartFarm.Schema

  schema "vaccinations" do
    field :vaccine_name, :string
    field :description, :string
    field :administration_mode, :string

    has_many :schedules, VaccinationSchedule

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:administration_mode, :vaccine_name, :description])
    |> validate_required([:administration_mode, :vaccine_name, :description])
  end
end
