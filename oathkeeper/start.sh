#!/bin/sh

function check() {
  curl --silent --output /dev/null http://localhost:4000/graphql -w "%{http_code}"
  return $?
}

while ! check ; do
  sleep 1 && echo waiting for GraphQL mesh server to start
done

exec s6-setuidgid ory /opt/oathkeeper/oathkeeper --config /opt/oathkeeper/config.yaml serve