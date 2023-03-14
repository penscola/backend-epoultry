defmodule SmartFarmWeb.APIAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :smart_farm,
    module: SmartFarm.Guardian

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
