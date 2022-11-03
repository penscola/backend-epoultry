defmodule SmartFarmWeb.Authorize do
  @moduledoc """
  This is the authorization plug
  """
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  alias SmartFarmWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "Please Login First")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end
