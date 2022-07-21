defmodule SmartFarmWeb.Middleware.Authorize do
  @behaviour Absinthe.Middleware

  @spec call(Absinthe.Resolution.t(), %{current_user: any()}) :: Absinthe.Resolution.t()
  def call(resolution = %{context: %{current_user: %_{} = _user}}, _config) do
    resolution
  end

  @spec call(Absinthe.Resolution.t(), term()) :: Absinthe.Resolution.t()
  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result({
      :error,
      %{code: :not_authenticated, error: "Not Authenticated", message: "Not Authenticated"}
    })
  end
end
