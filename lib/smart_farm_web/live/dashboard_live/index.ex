defmodule SmartFarmWeb.DashboardLive.Index do
  use SmartFarmWeb, :live_view

  alias SmartFarm.Dashboard

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    stats = Dashboard.dashboard()

    socket
    |> assign(:page_title, "Dashboard")
    |> assign(stats)
  end
end
