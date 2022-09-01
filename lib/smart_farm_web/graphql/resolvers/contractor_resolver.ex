defmodule SmartFarmWeb.Resolvers.Contractor do
  use SmartFarm.Shared

  @spec list(map(), %{context: %{current_user: %User{}}}) :: {:ok, [%Contractor{}, ...]}
  def list(_args, %{context: %{current_user: _user}}) do
    {:ok, Contractors.list_contractors()}
  end

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, [%Contractor{}, ...]}
  def get(%{contractor_id: id}, %{context: %{current_user: _user}}) do
    Contractors.get_contractor(id)
  end
end
