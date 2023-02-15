defmodule SmartFarm.Vaccinations.VaccinationSchedule do
  use SmartFarm.Schema

  schema "vaccination_schedules" do
    field :bird_type, Ecto.Enum, values: [:broilers, :layers, :kienyeji]
    field :repeat_after, :integer

    embeds_many :bird_ages, AgeRange do
      field :min, :integer
      field :max, :integer
    end

    belongs_to :vaccination, Vaccination

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:bird_type, :vaccination_id, :repeat_after])
    |> validate_required([:bird_type])
    |> cast_embed(:bird_ages, with: &age_range_changeset/2, required: true)
  end

  defp age_range_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:min, :max])
    |> validate_range()
  end

  defp validate_range(changeset) do
    max = get_field(changeset, :max)
    min = get_field(changeset, :min)

    cond do
      is_nil(min) and is_nil(max) ->
        changeset

      min && max && min > max ->
        add_error(changeset, :max, "must be greator than min")

      true ->
        validate_required(changeset, [:min, :max])
    end
  end
end
