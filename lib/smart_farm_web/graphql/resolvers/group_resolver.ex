defmodule SmartFarmWeb.Resolvers.Group do
  use SmartFarm.Shared

  @spec register_group(map(), %{context: map()}) :: {:ok, %Group{}} | {:error, Ecto.Changeset.t()}
  def register_group(args, _context) do
    Accounts.register_group(args.data)
  end
end
