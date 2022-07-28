defmodule SmartFarm.BatchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SmartFarm.Batches` context.
  """

  @doc """
  Generate a batch.
  """
  def batch_fixture(attrs \\ %{}) do
    {:ok, batch} =
      attrs
      |> Enum.into(%{
        acquired_date: ~D[2022-07-26],
        age_type: "some age_type",
        bird_age: 42,
        bird_count: 42,
        bird_type: "some bird_type",
        name: "some name"
      })
      |> SmartFarm.Batches.create_batch()

    batch
  end

  @doc """
  Generate a bird_count_report.
  """
  def bird_count_report_fixture(attrs \\ %{}) do
    {:ok, bird_count_report} =
      attrs
      |> Enum.into(%{
        quantity: 42,
        reason: "some reason",
        report_date: ~D[2022-07-27]
      })
      |> SmartFarm.Batches.create_bird_count_report()

    bird_count_report
  end
end
