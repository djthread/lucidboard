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

config :lucidboard, :default_theme, "dark"

config :lucidboard, :themes, ~w(light dark)

config :lucidboard, :timezone, "America/Detroit"

config :phoenix, :json_library, Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :oauth2, serializers: %{"application/json" => Jason}

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    pingfed:
      {Ueberauth.Strategy.PingFed,
       [default_scope: "openid profile email", send_redirect_uri: false]}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
