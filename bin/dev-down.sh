#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
docker-compose -p lb2_dev -f "$DIR/../assets/dev-env/docker-compose.yml" down
