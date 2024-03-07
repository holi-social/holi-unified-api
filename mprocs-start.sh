#!/bin/bash

# This file is used by the mprocs yaml files in https://gitlab.holi.team/app/holi-meta

. ../.envrc.local.backends
. ./.envrc.local
[ "$LOCAL_BACKEND_CHAT" = "true" ] && ../wait-for-port.sh 8008
../wait-for-port.sh 8000
../wait-for-port.sh 8001
../wait-for-port.sh 8002
../wait-for-port.sh 8003
../wait-for-port.sh 8004
../wait-for-port.sh 8005
../wait-for-port.sh 8006
yarn mesh build
cp logger.ts .mesh/
yarn serve
