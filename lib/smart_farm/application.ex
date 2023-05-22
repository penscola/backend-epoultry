defmodule SmartFarm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SmartFarm.Repo,
      # Start Oban workers
      goth_config(),
      {Oban, Application.fetch_env!(:smart_farm, Oban)},
      # Start the Telemetry supervisor
      SmartFarmWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SmartFarm.PubSub},
      # Start the Endpoint (http/https)
      SmartFarmWeb.Endpoint
      # Start a worker by calling: SmartFarm.Worker.start_link(arg)
      # {SmartFarm.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmartFarm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SmartFarmWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  if Mix.env() == :prod do
    defp goth_config() do
      credentials =
        "GOOGLE_APPLICATION_CREDENTIALS_JSON"
        |> System.fetch_env!()
        |> Jason.decode!()

      scopes = ["https://www.googleapis.com/auth/devstorage.read_write"]
      source = {:service_account, credentials, scopes: scopes}

      {Goth, name: SmartFarm.Goth, source: source}
    end
  else
    defp goth_config() do
      Supervisor.child_spec({Task, fn -> :ok end}, id: :goth_config)
    end
  end
end
