# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lucidboard,
  ecto_repos: [Lucidboard.Repo]

# Configures the endpoint
config :lucidboard, LucidboardWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "ynHoNC75BVRedbPP06+hVh6fj9+J2vP+K51G0J9F7xeeqYXSMpHJ4cYT1N70Qqlw",
  render_errors: [view: LucidboardWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Lucidboard.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :oauth2, GitHub,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: System.get_env("GITHUB_REDIRECT_URI")

config :oauth2, Google,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")

config :oauth2, Facebook,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET"),
  redirect_uri: System.get_env("FACEBOOK_REDIRECT_URI")

config :oauth2, PingFed,
  client_id: System.get_env("PINGFED_CLIENT_ID"),
  client_secret: System.get_env("PINGFED_CLIENT_SECRET"),
  redirect_uri: System.get_env("PINGFED_REDIRECT_URI")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
