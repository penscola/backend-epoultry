defmodule SmartFarm.Vaccinations.BatchVaccination do
  use SmartFarm.Schema

  schema "batch_vaccinations" do
    field :date_scheduled, :date
    field :date_completed, :utc_datetime

    belongs_to :batch, Batch
    belongs_to :completer, User

    belongs_to :vaccination_schedule, Vaccination,
      foreign_key: :vaccination_id,
      define_field: false

    belongs_to :vaccination, Vaccination

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [
      :date_scheduled,
      :date_completed,
      :batch_id,
      :completer_id,
      :vaccination_id
    ])
    |> validate_required([:date_scheduled, :batch_id, :vaccination_id])
  end
end
