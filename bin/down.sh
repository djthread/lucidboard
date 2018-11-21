#!/usr/bin/env bash
#
# Stops all our docker containers. Works with `dev.sh` or `db.sh`.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
docker-compose -p lb2_dev -f "$DIR/../assets/dev-env/docker-compose.yml" down
