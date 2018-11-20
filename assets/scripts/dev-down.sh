#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
docker-compose -f "$DIR/../dev-env/docker-compose.yml" down
