defmodule SmartFarm.Reports.FarmVisitReport do
  use SmartFarm.Schema

  schema "farm_visit_reports" do
    field :general_observation, :string
    field :recommendations, :string

    embeds_one :farm_information, FarmInfo do
      field :farm_officer_contact, :string
      field :farm_assistant_contact, :string
      field :age_type, Ecto.Enum, values: [:weeks, :days, :months]
      field :bird_age, :integer
      field :bird_type, Ecto.Enum, values: [:broilers, :layers, :kienyeji]
      field :remaining_bird_count, :integer
      field :mortality, :integer
      field :delivered_bird_count, :integer
    end

    embeds_one :housing_inspection, HousingInspection do
      field :bio_security, :string
      field :cobwebs, :string
      field :dust, :string
      field :lighting, :string
      field :ventilation, :string
      field :repair_and_maintainance, :string
      field :drinkers, :string
      field :feeders, :string
    end

    embeds_one :store, Store do
      field :stock_take, :string
      field :arrangement, :string
      field :cleanliness, :string
    end

    embeds_one :compound, Compound do
      field :landscape, :string
      field :security, :string
      field :tank_cleanliness, :string
    end

    embeds_one :farm_team, FarmTeam do
      field :cleanliness, :string
      field :uniforms, :string
      field :gumboots, :string
    end

    belongs_to :extension_service, ExtensionServiceRequest

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:general_observation, :recommendations, :extension_service_id])
    |> foreign_key_constraint(:extension_service_id)
    |> cast_embed(:farm_information, with: &farm_information_changeset/2, required: true)
    |> cast_embed(:housing_inspection, with: &housing_inspection_changeset/2, required: true)
    |> cast_embed(:store, with: &store_changeset/2, required: true)
    |> cast_embed(:compound, with: &compound_changeset/2, required: true)
    |> cast_embed(:farm_team, with: &farm_team_changeset/2, required: true)
  end

  defp farm_information_changeset(schema, attrs) do
    schema
    |> cast(attrs, [
      :farm_officer_contact,
      :farm_assistant_contact,
      :age_type,
      :bird_age,
      :bird_type,
      :remaining_bird_count,
      :mortality,
      :delivered_bird_count
    ])
    |> validate_required([
      :farm_officer_contact,
      :farm_assistant_contact,
      :age_type,
      :bird_age,
      :bird_type,
      :remaining_bird_count,
      :mortality,
      :delivered_bird_count
    ])
  end

  defp housing_inspection_changeset(schema, attrs) do
    schema
    |> cast(attrs, [
      :bio_security,
      :cobwebs,
      :dust,
      :lighting,
      :ventilation,
      :repair_and_maintainance,
      :drinkers,
      :feeders
    ])
    |> validate_required([
      :bio_security,
      :cobwebs,
      :dust,
      :lighting,
      :ventilation,
      :repair_and_maintainance,
      :drinkers,
      :feeders
    ])
  end

  defp store_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:stock_take, :arrangement, :cleanliness])
    |> validate_required([:stock_take, :arrangement, :cleanliness])
  end

  defp compound_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:landscape, :security, :tank_cleanliness])
    |> validate_required([:landscape, :security, :tank_cleanliness])
  end

  defp farm_team_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:cleanliness, :uniforms, :gumboots])
    |> validate_required([:cleanliness, :uniforms, :gumboots])
  end
end
