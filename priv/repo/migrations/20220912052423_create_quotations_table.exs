defmodule SmartFarm.Repo.Migrations.CreateQuotationsTable do
  use Ecto.Migration

  def change do
    create table(:quotation_requests) do
      add :user_id, references(:users)

      timestamps()
    end

    create table(:quotation_request_items) do
      add :name, :string
      add :quantity, :integer
      add :quotation_request_id, references(:quotation_requests)

      timestamps()
    end
  end
end
