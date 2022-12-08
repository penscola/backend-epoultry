defmodule SmartFarmWeb.ReportLive.Index do
  use SmartFarmWeb, :live_view

  alias SmartFarm.Farms
  alias SmartFarm.Accounts

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)
    {:ok, assign(socket, reports: [], current_user: current_user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Reports")
    |> assign(:reports, list_reports(params, socket.assigns.current_user))
  end

  defp apply_action(socket, :show, params) do
    socket
    |> assign(:page_title, "Farm Report")
    |> assign(:farm_report, get_report(params, socket.assigns.current_user))
    |> assign(:farm, get_farm(params))
  end

  defp list_reports(params, user) do
    with {:ok, reports} <- Farms.list_farm_reports(params, actor: user) do
      reports
    else
      _other ->
        []
    end
  end

  defp get_report(%{"farm_id" => farm_id, "date" => date}, user) do
    {:ok, report} = Farms.get_farm_report(farm_id, date, actor: user)
    report
  end

  defp get_farm(%{"farm_id" => farm_id}) do
    Farms.get_farm!(farm_id)
  end
end
