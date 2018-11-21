#!/usr/bin/env bash
#
# Lb2 docker-based dev environment starter
#
#   1. Write `dev.secret.exs` if it doesn't already exist
#   2. docker-compose up -d (runs postgres and elixir containers)
#   3. Run fish, a friendly shell
#
# Note that if you have Elixir installed to your system, you may like to run
# only postgres as a container. In this case, `db.sh` can be used instead of
# this script. (`down.sh` will still work.)
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
    -f "$DIR/../assets/dev-env/docker-compose.yml" \
    up -d

docker exec -it lb2_dev_app fish
