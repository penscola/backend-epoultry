defmodule SmartFarmWeb.VaccinationLive.FormComponent do
  use SmartFarmWeb, :live_component

  alias SmartFarm.Vaccinations

  @impl true
  def update(%{vaccination: vaccination} = assigns, socket) do
    changeset = Vaccinations.Vaccination.changeset(vaccination, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"vaccination" => vaccination_params}, socket) do
    changeset =
      socket.assigns.vaccination
      |> Vaccinations.Vaccination.changeset(vaccination_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"vaccination" => vaccination_params}, socket) do
    save_vaccination(socket, socket.assigns.action, vaccination_params)
  end

  defp save_vaccination(socket, :edit, vaccination_params) do
    case Vaccinations.update_vaccination(socket.assigns.vaccination, vaccination_params) do
      {:ok, _vaccination} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vaccination updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_vaccination(socket, :new, vaccination_params) do
    case Vaccinations.create_vaccination(vaccination_params) do
      {:ok, _vaccination} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vaccination created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
