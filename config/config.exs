# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lb2,
  ecto_repos: [Lb2.Repo]

# Configures the endpoint
config :lb2, Lb2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "ynHoNC75BVRedbPP06+hVh6fj9+J2vP+K51G0J9F7xeeqYXSMpHJ4cYT1N70Qqlw",
  render_errors: [view: Lb2Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Lb2.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
