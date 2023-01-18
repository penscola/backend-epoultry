defmodule SmartFarmWeb.Resolvers.Vaccination do
  use SmartFarm.Shared

  def get_batch_vaccination(args, %{context: %{current_user: user}}) do
    Vaccinations.get_batch_vaccination(args.vaccination_id, actor: user)
  end

  def list_batch_vaccinations(args, %{context: %{current_user: user}}) do
    {:ok, Vaccinations.list_batch_vaccinations(args, actor: user)}
  end

  def complete_batch_vaccination(args, %{context: %{current_user: user}}) do
    Vaccinations.complete_batch_vaccination(args.vaccination_id, actor: user)
  end

  def get_vaccination_status(vaccination, _args, %{context: %{current_user: _user}}) do
    {:ok, Vaccinations.get_vaccination_status(vaccination)}
  end
end
