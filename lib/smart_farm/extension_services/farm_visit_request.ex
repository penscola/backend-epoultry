defmodule SmartFarm.ExtensionServices.FarmVisitRequest do
  use SmartFarm.Schema

  @primary_key false
  schema "farm_visit_extension_services" do
    field :visit_date, :date
    field :visit_purpose, :string

    belongs_to :extension_service, ExtensionServiceRequest

    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:visit_date, :visit_purpose])
    |> validate_required([:visit_date, :visit_purpose])
  end
end
