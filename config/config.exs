# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :smart_farm,
  ecto_repos: [SmartFarm.Repo]

config :smart_farm, SmartFarm.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [
    type: :utc_datetime,
    inserted_at: :created_at,
    updated_at: :updated_at
  ]

config :smart_farm, Oban,
  repo: SmartFarm.Repo,
  prefix: "jobs",
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, scheduled: 10, uploads: 10]

config :smart_farm, SmartFarm.Guardian,
  issuer: "smart_farm",
  secret_key: "+sBqESBgDk/ea4rZcTd2BzhSVCAJfBU/UwQZaS48pPyZUIjlP7Hu7JUbVuxiVuQ6"

# Configures the endpoint
config :smart_farm, SmartFarmWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SmartFarmWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SmartFarm.PubSub,
  live_view: [signing_salt: "KpcxiYLd"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :smart_farm, SmartFarm.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :smart_farm, env: Mix.env()

config :elixir, :time_zone_database, Tz.TimeZoneDatabase
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
