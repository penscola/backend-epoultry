defmodule SmartFarmWeb.Schema.JSONType do
  use Absinthe.Schema.Notation

  scalar :json, name: "JSON" do
    serialize(&encode/1)
    parse(&decode/1)
  end

  defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
    case Jason.decode(value) do
      {:ok, result} -> {:ok, result}
      _ -> :error
    end
  end

  defp decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode(_) do
    :error
  end

  defp encode(value), do: value
end
