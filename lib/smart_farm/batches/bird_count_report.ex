defmodule SmartFarm.Batches.BirdCountReport do
  use SmartFarm.Schema

  schema "bird_count_reports" do
    field :quantity, :integer
    field :reason, Ecto.Enum, values: [:sold, :curled, :mortality, :stolen]
    field :selling_price, :integer

    belongs_to :report, Report

    timestamps()
  end

  @doc false
  def changeset(bird_count_report, attrs) do
    bird_count_report
    |> cast(attrs, [:quantity, :reason, :report_id, :selling_price])
    |> validate_required([:quantity, :reason])
  end
end
