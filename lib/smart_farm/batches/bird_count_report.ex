defmodule SmartFarm.Batches.BirdCountReport do
  use SmartFarm.Schema

  schema "bird_count_reports" do
    field :quantity, :integer
    field :reason, :string
    field :report_date, :date, autogenerate: {Date, :utc_today, []}

    belongs_to :batch, Batch
    belongs_to :reporter, User

    timestamps()
  end

  @doc false
  def changeset(bird_count_report, attrs) do
    bird_count_report
    |> cast(attrs, [:quantity, :reason, :report_date, :batch_id, :reporter_id])
    |> validate_required([:quantity, :reason])
  end
end
