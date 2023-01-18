defmodule SmartFarm.Vaccinations.VaccinationSchedule do
  use SmartFarm.Schema

  schema "vaccination_schedules" do
    field :bird_types, {:array, Ecto.Enum}, values: [:broilers, :layers, :kienyeji]
    field :bird_ages, {:array, :integer}
    field :vaccine_name, :string
    field :description, :string

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:bird_types, :bird_ages, :vaccine_name, :description])
    |> validate_required([:bird_types, :bird_ages, :vaccine_name, :description])
  end
end
