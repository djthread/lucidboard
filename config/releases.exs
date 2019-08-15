import Config

config :lucidboard, LucidboardWeb.Endpoint,
  url: [host: System.get_env("URL_HOST", "localhost")]

config :lucidboard, Lucidboard.Repo,
  database: System.get_env("PG_DB", "lucidboard_prod"),
  hostname: System.get_env("PG_HOST", "db"),
  port: System.get_env("PG_PORT", "5432"),
  password: System.get_env("PG_PASS", "verysecure123")

config :lucidboard,
       :auth_provider,
       String.to_atom(System.get_env("AUTH_PROVIDER", "dumb"))

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.PingFed.OAuth,
  site: System.get_env("PINGFED_SITE"),
  redirect_uri: System.get_env("PINGFED_REDIRECT_URI"),
  client_id: System.get_env("PINGFED_CLIENT_ID"),
  client_secret: System.get_env("PINGFED_CLIENT_SECRET")
