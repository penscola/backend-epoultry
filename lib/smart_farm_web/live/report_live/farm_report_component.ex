defmodule SmartFarmWeb.ReportLive.FarmReportComponent do
  use SmartFarmWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
