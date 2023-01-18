defmodule SmartFarm.SMS.AtClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, base_url()

  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/x-www-form-urlencoded"},
    {"Accept", "application/json"},
    {"apiKey", api_key()}
  ]

  plug Tesla.Middleware.EncodeFormUrlencoded
  plug Tesla.Middleware.KeepRequest
  plug Tesla.Middleware.DecodeJson

  defp base_url do
    if Application.get_env(:smart_farm, :env) == :dev do
      "https://api.sandbox.africastalking.com/version1"
    else
      "https://api.africastalking.com/version1"
    end
  end

  defp config do
    Application.get_env(:smart_farm, :africastalking) |> IO.inspect
  end

  defp api_key do
    config()[:api_key]
  end
end
