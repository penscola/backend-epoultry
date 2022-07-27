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
    "https://api.sandbox.africastalking.com/version1"
  end

  defp config do
    Application.get_env(:smart_farm, :africastalking)
  end

  defp api_key do
    config()[:api_key]
  end
end
