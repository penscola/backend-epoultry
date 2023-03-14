defmodule SmartFarmWeb.Middleware.ErrorHandler do
  @moduledoc false
  @behaviour Absinthe.Middleware

  @impl true
  def call(resolution, _config) do
    errors =
      resolution.errors
      |> List.flatten()
      |> Enum.map(&to_absinthe_format/1)
      |> List.flatten()

    %{resolution | errors: errors}
  end

  defp to_absinthe_format(%Ecto.Changeset{} = changeset) do
    for {key, errors} <- traverse_errors(changeset) do
      %{message: "#{key} " <> hd(errors), details: %{key => errors}}
    end
  end

  defp to_absinthe_format(error), do: error

  defp traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
