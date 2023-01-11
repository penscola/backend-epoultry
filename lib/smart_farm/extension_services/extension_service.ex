defmodule SmartFarm.ExtensionServices.ExtensionServiceRequest do
  use SmartFarm.Schema

  schema "extension_service_requests" do
    field :date_accepted, :utc_datetime
    field :date_cancelled, :utc_datetime
    belongs_to :acceptor, User
    belongs_to :requester, User
    belongs_to :farm, Farm
    has_one :medical_visit, MedicalVisitRequest, foreign_key: :extension_service_id
    has_one :farm_visit, FarmVisitRequest, foreign_key: :extension_service_id

    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:date_accepted, :date_cancelled, :farm_id])
    |> validate_required([:farm_id])
  end
end
