defmodule SmartFarmWeb.UserLive.Index do
  use SmartFarmWeb, :live_view

  alias SmartFarm.Accounts
  alias SmartFarm.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :users, list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, assign(socket, :users, list_users())}
  end

  defp list_users do
    Accounts.list_users_for_dashboard()
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
end
