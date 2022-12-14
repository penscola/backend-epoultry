defmodule SmartFarmWeb.Resolvers.Address do
  use SmartFarm.Shared

  def counties(_args, %{context: %{current_user: _user}}) do
    {:ok, Addresses.all_counties()}
  end

  def get_county(args, %{context: %{current_user: _user}}) do
    Addresses.get_county(args.code)
  end

  def get_subcounty(args, %{context: %{current_user: _user}}) do
    Addresses.get_subcounty(args.code)
  end
end
