defmodule SmartFarm.Batches.Report do
  use SmartFarm.Schema

  schema "batches_reports" do
    field :report_date, :date, autogenerate: {Date, :utc_today, []}
    belongs_to :batch, Batch
    belongs_to :reporter, User
    has_many :bird_counts, BirdCountReport
    has_one :egg_collection, EggCollectionReport

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:report_date, :batch_id, :reporter_id])
    |> validate_required([:report_date])
  end
end
