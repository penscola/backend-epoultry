defmodule SmartFarm.Util.CodeGenerator do
  def generate(n \\ 4) do
    "~#{n}..0B"
    |> :io_lib.format([(10 |> :math.pow(n) |> round() |> :rand.uniform()) - 1])
    |> List.to_string()
  end
end
