defmodule SmartFarm.ExtensionServices.MedicalVisitRequest do
  use SmartFarm.Schema

  @primary_key false
  schema "medical_visit_extension_services" do
    field :bird_type, :string
    field :bird_age, :float
    field :age_type, Ecto.Enum, values: [:weeks, :days, :months]
    field :bird_count, :integer
    field :description, :string

    belongs_to :extension_service, ExtensionServiceRequest

    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:bird_type, :bird_age, :age_type, :bird_count, :description])
    |> validate_required([:bird_type, :bird_age, :age_type, :bird_count, :description])
  end
end
