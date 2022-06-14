#!/bin/sh

# wait for node process having opened the port
while ! wget --spider -q --post-data '{"query":"query{allUsers{id}}"}' --header 'content-type: application/json'  localhost:4000/graphql ; do 
  sleep 1 && echo waiting for node
done
/opt/oathkeeper/oathkeeper --config /opt/oathkeeper/config.yaml serve