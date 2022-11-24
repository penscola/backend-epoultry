defmodule SmartFarmWeb.ReportLive.FarmReportComponent do
  use SmartFarmWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  defp batch_names(reports) do
    reports
    |> Enum.map(fn report ->
      report.batch.name
    end)
    |> Enum.join(",")
  end
end
