#!/bin/bash

# This file is used by the mprocs yaml files in https://gitlab.holi.team/app/holi-meta 

docker run \
  --rm \
  --name ory-oathkeeper-unified-api \
  -p 0.0.0.0:4455:4455 \
  -p 0.0.0.0:4456:4456 \
  --env-file=.env.local \
  --mount type=bind,source="$PWD",target=/opt/oathkeeper/ \
  --add-host=host.docker.internal:host-gateway \
  oryd/oathkeeper:v0.40.9 --config /opt/oathkeeper/config.yaml serve
