defmodule SmartFarmWeb.Schema.UUIDType do
  use Absinthe.Schema.Notation

  alias Ecto.UUID

  scalar :uuid, name: "UUID" do
    serialize(&encode/1)
    parse(&decode/1)
  end

  defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
    UUID.cast(value)
  end

  defp decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode(_) do
    :error
  end

  defp encode(value), do: value
end
