defmodule SmartFarm.Reports.Report do
  use SmartFarm.Schema

  schema "batches_reports" do
    field :report_date, :date, autogenerate: {Date, :utc_today, []}
    belongs_to :batch, Batch
    belongs_to :reporter, User
    has_many :bird_counts, BirdCountReport
    has_one :egg_collection, EggCollectionReport
    has_many :store_reports, StoreItemUsageReport

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:report_date, :batch_id, :reporter_id])
    |> unique_constraint([:report_date, :batch_id])
  end

  def by_id(query, ids) when is_list(ids) do
    from r in query, join: b in assoc(r, :batch), preload: [batch: b], where: r.id in ^ids
  end
end
