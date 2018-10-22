#!/bin/bash
set -e

docker-compose run backend_dev mix credo --strict

docker-compose run backend_dev mix dialyzer --halt-exit-status
