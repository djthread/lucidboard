#!/usr/bin/env bash
#
# Writes `dev.secret.exs` if it doesn't already exist.
#
# Exits with 0 if the file is written. 1 if not.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SECRETFILE="$DIR/../config/dev.secret.exs"

if [ ! -f "$SECRETFILE" ]; then
    cat << EOF > "$SECRETFILE"
use Mix.Config

config :lb2, Lb2.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER") || "postgres",
  password: System.get_env("PG_PASS") || "verysecure123",
  database: System.get_env("PG_DB") || "lb2",
  hostname: System.get_env("PG_HOST") || "localhost",
  pool_size: 10
EOF
    exit 0
fi

exit 1