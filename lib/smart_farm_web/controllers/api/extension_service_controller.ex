defmodule SmartFarmWeb.API.ExtensionServiceController do
  use SmartFarmWeb, :controller
  alias SmartFarm.Accounts.User
  alias SmartFarm.ExtensionServices

  def create_medical_visit(conn, %{"batchId" => batch_id, "description" => description} = params) do
    with %User{} = user <- Guardian.Plug.current_resource(conn),
         {:ok, extension_service_request} <-
           ExtensionServices.request_medical_visit(
             %{
               batch_id: batch_id,
               description: description,
               attachments: attachment_files(params["attachments"])
             },
             actor: user
           ) do
      conn
      |> put_status(200)
      |> json(%{extension_service_request: %{id: extension_service_request.id}})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> json(%{error: stringify_changeset_errors(changeset)})

      nil ->
        conn
        |> put_status(403)
        |> json(%{error: "Who are you ):"})
    end
  end

  defp attachment_files(nil), do: nil

  defp attachment_files(%_{} = upload) do
    [upload]
  end

  defp attachment_files(attachments) do
    attachments
    |> Enum.map(fn
      {_key, upload} ->
        upload

      upload ->
        upload
    end)
  end

  defp stringify_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {key, errors}, acc ->
      errors
      |> Enum.map_join(", ", fn error -> "#{key} " <> error end)
      |> String.replace_prefix("", acc)
    end)
  end
end
