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

# import_config "#{Mix.env}.secret.exs"
