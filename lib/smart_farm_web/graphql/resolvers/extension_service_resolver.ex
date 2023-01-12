defmodule SmartFarmWeb.Resolvers.ExtensionService do
  use SmartFarm.Shared

  def list_extension_service_requests(%{filter: filter}, %{context: %{current_user: user}}) do
    {:ok, ExtensionServices.list_extension_service_requests(filter, actor: user)}
  end

  def request_farm_visit(%{data: data}, %{context: %{current_user: user}}) do
    ExtensionServices.request_farm_visit(data, actor: user)
  end

  def request_medical_visit(%{data: data}, %{context: %{current_user: user}}) do
    ExtensionServices.request_medical_visit(data, actor: user)
  end

  def request_status(request, _args, %{context: %{current_user: _user}}) do
    {:ok, ExtensionServices.get_request_status(request)}
  end
end
