defmodule SmartFarm.Repo.Migrations.AddSellingPriceToBirdCountReports do
  use Ecto.Migration

  def change do
    alter table(:bird_count_reports) do
      add :selling_price, :integer
    end
  end
end
