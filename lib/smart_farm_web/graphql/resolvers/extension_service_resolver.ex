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

  def accept_extension_request(args, %{context: %{current_user: user}}) do
    ExtensionServices.accept_extension_request(args.extension_service_id, actor: user)
  end

  def cancel_extension_request(args, %{context: %{current_user: user}}) do
    ExtensionServices.cancel_extension_request(args.extension_service_id, actor: user)
  end

  def create_farm_visit_report(args, %{context: %{current_user: user}}) do
    ExtensionServices.create_farm_visit_report(args.data, actor: user)
  end
end
