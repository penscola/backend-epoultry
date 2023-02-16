defmodule SmartFarmWeb.VaccinationLive.Index do
  use SmartFarmWeb, :live_view
  use SmartFarm.Shared

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)

    {:ok,
     assign(socket, schedules: [], vaccination: nil, vaccinations: [], current_user: current_user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :schedule, _params) do
    socket
    |> assign(:page_title, "Vaccination Schedules")
    |> assign(:schedules, schedules())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Vaccines")
    |> assign(:vaccinations, Vaccinations.list_vaccinations())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Vaccination")
    |> assign(:vaccination, %Vaccination{})
  end

  defp schedules do
    Vaccinations.list_vaccination_schedules()
    |> Enum.group_by(& &1.bird_type)
    |> Enum.map(fn {key, schedules} ->
      schedules =
        schedules
        |> Enum.map(fn schedule ->
          Enum.map(schedule.bird_ages, fn range -> {range, schedule} end)
        end)
        |> List.flatten()

      {key, Enum.sort_by(schedules, fn {range, _schedule} -> range.min end, :asc)}
    end)
  end

  defp age_range_count(vaccination) do
    vaccination.schedules
    |> Enum.map(& &1.bird_ages)
    |> List.flatten()
    |> Enum.count()
  end

  defp readable_age(age_range) do
    if age_range.min == age_range.max do
      "#{age_range.min}"
    else
      "#{age_range.min} - #{age_range.max}"
    end
  end
end
