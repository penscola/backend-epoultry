defmodule SmartFarmWeb.SessionController do
  use SmartFarmWeb, :controller
  alias SmartFarm.Accounts
  alias SmartFarm.Accounts.User
  alias SmartFarmWeb.Auth

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number, "password" => password}}) do
    case Auth.login_user(conn, phone_number, password) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> redirect(to: Routes.dashboard_index_path(conn, :index))

      {:error, :unauthorized, conn} ->
        conn
        |> put_flash(:error, "Invalid phone number or password")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, :not_found, conn} ->
        conn
        |> put_flash(:error, "User does not exist")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout()
    |> put_flash(:info, "You have logged out")
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
