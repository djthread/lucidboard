#!/usr/bin/env bash
#
# Starts the Postgres container only (with port 5432 open). Use this if you
# prefer to use your system-installed instance of Elixir.
#
# Use dev.sh to start it *with* the elixir container.
#
# Steps:
#
#   1. Write `dev.secret.exs` if it doesn't already exist
#   2. Start postgres, volume-mounted to `assets/db-docker-data`
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if "$DIR/maybe_create_secret_file.sh"; then
    cat << EOF
Elixir development environment initialized!

To install dependencies and set up the database, run the following commanads:

    mix deps.get
    cd assets; npm install; cd ..
    mix ecto.setup

(Or execute these commands with the shortcut - \`setup\`)

EOF
fi

docker-compose -p lb2_dev \
    -f assets/dev-env/docker-compose.yml \
    run -d \
    -p 5432:5432 \
    --name lb2_dev_db \
    db && \
    echo "Postgres started. Listening on localhost:5432."
