defmodule SmartFarmWeb.QuotationRequestLive.Index do
  use SmartFarmWeb, :live_view

  alias SmartFarm.Accounts
  alias SmartFarm.Quotations
  alias SmartFarm.Quotations.Quotation
  alias SmartFarm.Quotations.QuotationItem
  alias SmartFarm.Repo

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)
    {:ok, assign(socket, requests: [], current_user: current_user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Quotation Requests")
    |> assign(:requests, quotation_requests(params))
  end

  defp apply_action(socket, :show_quotation, %{"requested_item_id" => id}) do
    quotation = get_quotation!(id)

    socket
    |> assign(:page_title, quotation.title)
    |> assign(:quotation, quotation)
  end

  defp apply_action(socket, :new_quotation, %{"requested_item_id" => id}) do
    item = get_requested_item!(id)

    quotation = %Quotation{
      title: "Quotation for #{item.quantity} #{item.name}",
      items: [
        %QuotationItem{id: "1", name: "equipments", quantity: 1},
        %QuotationItem{id: "2", name: "production", quantity: 1},
        %QuotationItem{id: "3", name: "housing", quantity: 1}
      ]
    }

    socket
    |> assign(:page_title, "Create Quotation")
    |> assign(:requested_item, item)
    |> assign(:requesting_user, item.quotation_request.user)
    |> assign(:quotation, quotation)
  end

  defp quotation_requests(_params) do
    Quotations.list_quotation_requests()
  end

  defp get_quotation!(request_id) do
    Quotation
    |> Repo.get_by!(requested_item_id: request_id)
    |> Repo.preload([:user, :items])
  end

  defp get_requested_item!(id) do
    Quotations.QuotationRequestItem
    |> Repo.get!(id)
    |> Repo.preload(quotation_request: [:user])
  end
end
