defmodule SmartFarm.Batches.Batch do
  use SmartFarm.Schema

  schema "batches" do
    field :acquired_date, :date
    field :age_type, Ecto.Enum, values: [:weeks, :days, :months]
    field :bird_age, :integer
    field :bird_count, :integer
    field :bird_type, Ecto.Enum, values: [:broilers, :layers, :kienyeji]
    field :name, :string
    field :todays_submission, :boolean, virtual: true

    belongs_to :creator, User
    belongs_to :farm, Farm
    has_many :reports, Report, preload_order: [desc: :report_date]

    timestamps()
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [
      :name,
      :bird_type,
      :bird_count,
      :bird_age,
      :age_type,
      :acquired_date,
      :creator_id,
      :farm_id
    ])
    |> validate_required([:name, :bird_type, :bird_count, :bird_age, :age_type, :acquired_date])
  end

  def todays_submission_query do
    today = Date.utc_today()

    from b in Batch,
      left_join: r in assoc(b, :reports),
      on: r.report_date == ^today,
      select: %{b | todays_submission: r.report_date == ^today}
  end
end
