# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :butler,
  ecto_repos: [Butler.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :butler, ButlerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zMMvioTGgb596RkIm651/cjTYRWXm9H7lzvbvrTr+Ks4Czct7G8XEt+tlSVdlqHQ",
  render_errors: [view: ButlerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Butler.PubSub,
  live_view: [signing_salt: "Vz4UXI+v"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
