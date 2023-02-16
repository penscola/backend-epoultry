defmodule SmartFarm.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up do
    Oban.Migrations.up(version: 11, prefix: "jobs")
  end

  def down do
    Oban.Migrations.down(version: 1, prefix: "jobs")
  end
end
