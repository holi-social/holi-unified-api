#!/bin/bash

# This file is used by the mprocs yaml files in https://gitlab.holi.team/app/holi-meta

. ../.envrc.local.backends
. ./.envrc.local
[ "$LOCAL_BACKEND_CHAT" = "true" ] && ../wait-for-port.sh 8008 chat-server
../wait-for-port.sh 8000 okuna
../wait-for-port.sh 8001 app-donations
../wait-for-port.sh 8002 app-goodnews
../wait-for-port.sh 8003 geo-api
../wait-for-port.sh 8004 app-volunteering
../wait-for-port.sh 8005 notifications
../wait-for-port.sh 8006 app-events
../wait-for-port.sh 8089 translation-api
../wait-for-port.sh 3001 moderation
yarn mesh build
cp logger.ts .mesh/
yarn serve
