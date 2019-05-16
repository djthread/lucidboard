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
  pubsub: [name: Lucidboard.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "OcXvrFwwOpyqvo+oCIbpdeEdOKmvt3zs"
  ]

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

config :lucidboard, :templates, %{
  "Retrospective" => %{
    columns: ["What Went Well", "What Didn't Go Well", "Propouts"]
  }
}

config :lucidboard, :default_theme, "minty"

config :lucidboard, :themes, ~w(minty darkly)

config :phoenix, :json_library, Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  site: "https://git.rockfin.com",
  authorize_url: "https://git.rockfin.com/login/oauth/authorize",
  token_url: "https://git.rockfin.com/login/oauth/access_token"
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
