defmodule SmartFarmWeb.Resolvers.Address do
  use SmartFarm.Shared

  def counties(_args, %{context: %{current_user: _user}}) do
    {:ok, Addresses.all_counties()}
  end
end
