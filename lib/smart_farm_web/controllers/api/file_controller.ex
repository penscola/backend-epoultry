defmodule SmartFarmWeb.API.FileController do
  use SmartFarmWeb, :controller
  alias SmartFarm.Accounts
  alias SmartFarm.Accounts.User

  def create_avatar(conn, %{"avatar" => upload}) do
    with %User{} = user <- Guardian.Plug.current_resource(conn),
         {:ok, user} <- Accounts.update_user_avatar(upload, actor: user) do
      conn
      |> put_status(200)
      |> json(%{user: %{id: user.id, avatar_id: user.avatar_id}})
    else
      _error ->
        conn
        |> put_status(400)
        |> json(%{error: "Failed to upload avatar"})
    end
  end
end
