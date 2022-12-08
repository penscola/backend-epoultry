defmodule SmartFarmWeb.QuotationRequestLive.QuoteComponent do
  use SmartFarmWeb, :live_component

  alias SmartFarm.Quotations

  @impl true
  def update(%{quotation: quotation} = assigns, socket) do
    changeset = Quotations.Quotation.changeset(quotation, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"quotation" => quotation_params}, socket) do
    changeset =
      socket.assigns.quotation
      |> Quotations.Quotation.changeset(quotation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"quotation" => quotation_params}, socket) do
    save_quotation(socket, socket.assigns.action, quotation_params)
  end

  # defp save_quotation(socket, :edit, quotation_params) do
  #   case Quotations.update_quotation(socket.assigns.quotation, quotation_params) do
  #     {:ok, _quotation} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Quotation updated successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

  defp save_quotation(%{assigns: assigns} = socket, :new_quotation, quotation_params) do
    params =
      Map.merge(quotation_params, %{
        "user_id" => assigns.requesting_user.id,
        "requested_item_id" => assigns.requested_item.id
      })

    case Quotations.create_quotation(params) do
      {:ok, _quotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Quotation created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
