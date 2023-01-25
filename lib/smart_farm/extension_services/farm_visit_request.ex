defmodule SmartFarm.ExtensionServices.FarmVisitRequest do
  use SmartFarm.Schema

  @primary_key false
  schema "farm_visit_extension_services" do
    field :visit_date, :date
    field :visit_purpose, :string
    field :description, :string

    belongs_to :extension_service, ExtensionServiceRequest

    has_one :report, FarmVisitReport,
      foreign_key: :extension_service_id,
      references: :extension_service_id

    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:visit_date, :visit_purpose])
    |> validate_required([:visit_date, :visit_purpose])
  end
end
