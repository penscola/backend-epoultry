defmodule SmartFarmWeb.VaccinationLive.ScheduleFormComponent do
  use SmartFarmWeb, :live_component

  alias SmartFarm.Vaccinations
  alias SmartFarm.Vaccinations.VaccinationSchedule

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        let={f}
        for={@changeset}
        id="vaccination-schedule-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="columns">
          <div class="field column">
            <%= label(f, :bird_type) %>
            <div>
              <span class="select">
                <%= select(f, :bird_type, [:broilers, :layers, :kienyeji], required: true) %>
              </span>
            </div>
            <%= error_tag(f, :bird_type) %>
          </div>

          <div class="field column">
            <%= label(f, :repeat_after) %>
            <%= number_input(f, :repeat_after, class: "input") %>
            <p class="help">do not fill in if the schedule does not repeat</p>
            <%= error_tag(f, :repeat_after) %>
          </div>
        </div>

        <label class="label is-medium">Schedule in Days</label>
        <p class="help">
          If it is a single day and not a range, key in the same value in start and end day.
        </p>
        <%= inputs_for f, :bird_ages, [append: append_bird_ages(@vaccination_schedule.bird_ages)], fn fb -> %>
          <div class="columns">
            <div class="field column">
              <%= label(fb, :min, "Start Day") %>
              <%= number_input(fb, :min, class: "input") %>
              <%= error_tag(fb, :min) %>
            </div>
            <div class="field column">
              <%= label(fb, :max, "End Day") %>
              <%= number_input(fb, :max, class: "input") %>
              <%= error_tag(fb, :max) %>
            </div>
          </div>
        <% end %>

        <div class="is-flex is-flex-direction-row-reverse">
          <%= submit("Save", phx_disable_with: "Saving...", class: "button is-primary is-right") %>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{vaccination_schedule: vaccination_schedule} = assigns, socket) do
    changeset = VaccinationSchedule.changeset(vaccination_schedule, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"vaccination_schedule" => params}, socket) do
    changeset =
      socket.assigns.vaccination_schedule
      |> VaccinationSchedule.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"vaccination_schedule" => params}, socket) do
    save_vaccination_schedule(socket, socket.assigns.action, params)
  end

  defp save_vaccination_schedule(socket, :edit_schedule, params) do
    params = remove_empty_ranges(params)

    case Vaccinations.update_vaccination_schedule(
           socket.assigns.vaccination_schedule,
           params
         ) do
      {:ok, _vaccination_schedule} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vaccination Schedule updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_vaccination_schedule(socket, :new_schedule, params) do
    params = remove_empty_ranges(params) |> IO.inspect()

    case Vaccinations.create_vaccination_schedule(
           socket.assigns.vaccination,
           params
         ) do
      {:ok, _vaccination_schedule} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vaccination Schedule created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp append_bird_ages(current_ages) do
    for _i <- 1..max_age_count(current_ages) do
      %VaccinationSchedule.AgeRange{}
    end
  end

  defp max_age_count(current_ages) do
    if length(current_ages) >= 5 do
      1
    else
      5 - length(current_ages)
    end
  end

  defp remove_empty_ranges(%{"bird_ages" => ranges} = params) do
    ranges =
      ranges
      |> Enum.reject(fn {_key, val} ->
        val
        |> Map.values()
        |> Enum.all?(&(&1 == ""))
      end)
      |> Enum.into(%{})

    %{params | "bird_ages" => ranges}
  end

  defp remove_empty_ranges(params), do: params
end
