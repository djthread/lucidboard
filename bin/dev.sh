#!/usr/bin/env bash
#
# Lucidboard2 docker-based dev environment starter
#
#   1. Write `dev.secret.exs` if it doesn't already exist
#   2. docker-compose up -d (runs postgres and elixir containers)
#   3. Run fish, a friendly shell
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SECRETFILE="$DIR/../config/dev.secret.exs"

if [ ! -f "$SECRETFILE" ]; then
    cat << EOF > "$SECRETFILE"
use Mix.Config

config :lb2, Lb2.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER"),
  password: System.get_env("PG_PASS"),
  database: System.get_env("PG_DB"),
  hostname: System.get_env("PG_HOST"),
  pool_size: 10
EOF

cat << EOF
Elixir development environment initialized!

To install dependencies and set up the database, run the following commanads:

    mix deps.get
    cd assets; npm install; cd ..
    mix ecto.create
    mix ecto.migrate

(Or execute these commands with the shortcut - \`setup\`)

EOF
fi

docker-compose -p lb2_dev -f "$DIR/../assets/dev-env/docker-compose.yml" up -d

docker exec -it lb2_dev_app fish
