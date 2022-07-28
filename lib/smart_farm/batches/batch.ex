defmodule SmartFarm.Batches.Batch do
  use SmartFarm.Schema

  schema "batches" do
    field :acquired_date, :date
    field :age_type, :string
    field :bird_age, :integer
    field :bird_count, :integer
    field :bird_type, :string
    field :name, :string

    belongs_to :creator, User
    belongs_to :farm, Farm
    has_many :reports, Report

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
end
