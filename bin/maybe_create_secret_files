#!/usr/bin/env bash
#
# Writes `dev.secret.exs` and `test.secret.exs` if they don't already exist.
#
# Exits with 0 if the files are both written. 1 if not.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DEVSECRETFILE="$DIR/../config/dev.secret.exs"
TESTSECRETFILE="$DIR/../config/test.secret.exs"

if [ ! -f "$DEVSECRETFILE" ]; then
    cat << EOF > "$DEVSECRETFILE"
use Mix.Config

config :lb2, Lb2.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER") || "postgres",
  password: System.get_env("PG_PASS") || "verysecure123",
  database: System.get_env("PG_DB") || "lb2",
  hostname: System.get_env("PG_HOST") || "localhost",
  pool_size: 10
EOF

    if [ ! -f "$TESTSECRETFILE" ]; then
        cp "$DEVSECRETFILE" "$TESTSECRETFILE"
        exit 0
    fi
fi

exit 1
