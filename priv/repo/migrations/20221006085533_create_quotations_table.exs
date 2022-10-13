defmodule SmartFarm.Repo.Migrations.CreateQuotationsTable do
  use Ecto.Migration

  def change do
    create table(:quotations) do
      add :user_id, references(:users)
      add :requested_item_id, references(:quotation_request_items)
      add :title, :string
      add :total_cost, :integer

      timestamps()
    end

    create table(:quotation_items) do
      add :name, :string
      add :quantity, :integer
      add :unit_cost, :integer
      add :total_cost, :integer
      add :quotation_id, references(:quotations)

      timestamps()
    end

    create table(:clusters) do
      add :bird_type, :string
      add :min_count, :integer
      add :max_count, :integer
      add :pricing, :jsonb

      timestamps()
    end
  end
end
