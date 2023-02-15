defmodule SmartFarmWeb.VaccinationLive.Show do
  use SmartFarmWeb, :live_view
  use SmartFarm.Shared

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)

    {:ok, assign(socket, vaccination: nil, current_user: current_user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Vaccination")
    |> assign(:vaccination, Vaccinations.get_vaccination!(id))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    vaccination = Vaccinations.get_vaccination!(id)

    socket
    |> assign(:page_title, "Vaccine Details")
    |> assign(:vaccination, vaccination)
  end

  defp apply_action(socket, :new_schedule, %{"id" => id}) do
    vaccination = Vaccinations.get_vaccination!(id)

    socket
    |> assign(:page_title, "New Vaccination Schedule")
    |> assign(:vaccination, vaccination)
    |> assign(:vaccination_schedule, %VaccinationSchedule{bird_ages: []})
  end

  defp to_html(content) do
    raw(String.replace(content, "\n", "<br>"))
  end
end
