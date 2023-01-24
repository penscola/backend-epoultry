defmodule SmartFarmWeb.UserLive.Index do
  use SmartFarmWeb, :live_view

  alias SmartFarm.Accounts
  alias SmartFarm.Accounts.User

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    {:ok, assign(socket, users: [], current_user: user, user: nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("approve-vet-officer", %{"user_id" => user_id}, socket) do
    case Accounts.approve_vet_officer(user_id, actor: socket.assigns.current_user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vet Officer approved successfully")
         |> push_patch(to: Routes.user_index_path(socket, socket.assigns.live_action))}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Oops! An error occured while approving vet officer")
         |> push_patch(to: Routes.user_index_path(socket, socket.assigns.live_action))}
    end
  end

  @impl true
  def handle_event("approve-extension-officer", %{"user_id" => user_id}, socket) do
    case Accounts.approve_extension_officer(user_id, actor: socket.assigns.current_user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Extension Officer approved successfully")
         |> push_patch(to: Routes.user_index_path(socket, socket.assigns.live_action))}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Oops! An error occured while approving officer")
         |> push_patch(to: Routes.user_index_path(socket, socket.assigns.live_action))}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :farmer_index, params) do
    socket
    |> assign(:page_title, "Farmers")
    |> assign(:users, list_farmers(socket.assigns.current_user, params))
  end

  defp apply_action(socket, :farm_manager_index, params) do
    socket
    |> assign(:page_title, "Farm Managers")
    |> assign(:users, list_farm_managers(socket.assigns.current_user, params))
  end

  defp apply_action(socket, :extension_officer_index, params) do
    socket
    |> assign(:page_title, "Extension Officers")
    |> assign(:users, list_extension_officers(socket.assigns.current_user, params))
  end

  defp apply_action(socket, :vet_officer_index, params) do
    socket
    |> assign(:page_title, "Vetinary Officers")
    |> assign(:users, list_vet_officers(socket.assigns.current_user, params))
  end

  defp list_vet_officers(user, params) do
    Accounts.list_vet_officers(params, actor: user)
  end

  defp list_extension_officers(user, params) do
    Accounts.list_extension_officers(params, actor: user)
  end

  defp list_farm_managers(user, params) do
    Accounts.list_farm_managers(params, actor: user)
  end

  defp list_farmers(user, params) do
    Accounts.list_farmers(params, actor: user)
  end

  defp mask_phone_number(number) when is_binary(number) do
    with {:ok, number} <- User.format_phone_number(number) do
      <<"254", first::binary-size(3), _middle::binary-size(4), last::binary>> = number
      "254" <> first <> "****" <> last
    else
      _other ->
        number
    end
  end

  defp mask_phone_number(number), do: number

  defp user_status(%{date_approved: nil}) do
    "pending"
  end

  defp user_status(%{date_approved: %DateTime{}}) do
    "approved"
  end
end
