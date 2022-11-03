defmodule SmartFarmWeb.Auth do
  @moduledoc """
  This is the authentication plug
  """
  import Plug.Conn
  alias SmartFarm.Accounts
  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      user_id = get_session(conn, :user_id)
      user = user_id && get_user(user_id)
      assign(conn, :current_user, user)
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
