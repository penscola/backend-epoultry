defmodule SmartFarmWeb.Auth do
  @moduledoc """
  This is the authentication plug
  """
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  alias SmartFarm.Accounts
  alias SmartFarmWeb.Router.Helpers, as: Routes

  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && get_user(user_id)
    assign(conn, :current_user, user)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  def login_user(conn, phone, password) do
    case Accounts.verify_admin_credentials(phone, password) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found} -> {:error, :not_found, conn}
    end
  end

  def login(conn, admin) do
    conn
    |> assign(:current_user, admin)
    |> put_session(:user_id, admin.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end

  def user_role(user) do
    user.role.role |> String.to_atom()
  end

  defp get_user(user_id) do
    with {:ok, user} <- Accounts.get_user(user_id) do
      user
    else
      _other ->
        nil
    end
  end
end
