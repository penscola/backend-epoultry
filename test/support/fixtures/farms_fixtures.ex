defmodule SmartFarm.FarmsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SmartFarm.Farms` context.
  """

  @doc """
  Generate a farm.
  """
  def farm_fixture(attrs \\ %{}) do
    {:ok, farm} =
      attrs
      |> Enum.into(%{
        location: %{},
        name: "some name"
      })
      |> SmartFarm.Farms.create_farm()

    farm
  end
end
