#!/bin/sh

# wait for node process having opened the port
# sadly, we need to send a correct request that leads to a 200 response, because only then does the return code tell us the difference
# about the port being open or not. Therefore we implemented a simple ping query.
while ! wget --spider -q --post-data '{"query":"{ping}"}' --header 'content-type: application/json'  localhost:4000/graphql ; do 
  sleep 1 && echo waiting for node
done
exec s6-setuidgid ory /opt/oathkeeper/oathkeeper --config /opt/oathkeeper/config.yaml serve