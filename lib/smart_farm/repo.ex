defmodule SmartFarm.Repo do
  use Ecto.Repo,
    otp_app: :smart_farm,
    adapter: Ecto.Adapters.Postgres
end
