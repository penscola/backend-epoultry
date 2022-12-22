defmodule SmartFarmWeb.Schema.EATDatetimeType do
  use Absinthe.Schema.Notation

  scalar :eatdatetime, name: "EATDatetime" do
    serialize(&encode/1)
    parse(&decode/1)
  end

  defp encode(value) when is_struct(value, DateTime) do
    with {:ok, datetime} <- DateTime.shift_zone(value, "Africa/Nairobi") do
      DateTime.to_iso8601(datetime)
    else
      _error ->
        :error
    end
  end

  defp encode(value) do
    DateTime.to_iso8601(value)
  end

  defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
    with {:ok, datetime} <- NaiveDateTime.from_iso8601(value),
         {:ok, datetime2} <- DateTime.from_naive(datetime, "Africa/Nairobi"),
         {:ok, datetime3} <- DateTime.shift_zone(datetime2, "Etc/UTC") do
      {:ok, datetime3}
    else
      _error ->
        :error
    end
  end

  defp decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode(_) do
    :error
  end
end
