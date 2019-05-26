use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lucidboard, LucidboardWeb.Endpoint,
  http: [port: 8801],
  server: false

config :lucidboard, Lucidboard.Repo, pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn

config :lucidboard, Lucidboard.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER") || "postgres",
  password: System.get_env("PG_PASS") || "verysecure123",
  database: System.get_env("PG_DB") || "lucidboard_test",
  hostname: System.get_env("PG_HOST") || "localhost",
  pool_size: 10

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [ default_scope: "user:email" ]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET") #,
#site: "https://git.rockfin.com",
#authorize_url: "https://git.rockfin.com/login/oauth/authorize",
#token_url: "https://git.rockfin.com/login/oauth/access_token"
