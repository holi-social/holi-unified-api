FROM europe-north1-docker.pkg.dev/holi-shared/docker-hub-remote/node:20.16.0-alpine

# shell sanity with pipes (https://github.com/hadolint/hadolint/wiki/DL4006)
# needed for installation of s6
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# s6 for running ory oathkeeper proxy in the same container
ARG S6_OVERLAY_VERSION=3.1.0.1
RUN wget -c -q https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -O - | tar -xJpC /
RUN wget -c -q https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -O - | tar -xJpC /
ENTRYPOINT ["/init"]

# start oathkeeper only when node is running (but we still need to wait until node opened the port, see oathkeeper/start.sh)
ENV S6_CMD_WAIT_FOR_SERVICES=1

# install oathkeeper
RUN apk -U upgrade && apk --latest add curl ca-certificates
RUN addgroup -S ory; adduser -S ory -G ory -D -H -s /bin/nologin
# hadolint ignore=SC3001
RUN sh <(wget -c -q https://raw.githubusercontent.com/ory/meta/master/install.sh -O -) -d -b /opt/oathkeeper oathkeeper v0.40.7

# set up oathkeeper as background daemon
COPY s6/run s6/finish /etc/services.d/node/

# TODO https://github.com/just-containers/s6-overlay#dropping-privileges

# copy oathkeeper config
COPY oathkeeper/config.yaml oathkeeper/rules-production.yaml oathkeeper/rules-staging.yaml oathkeeper/start.sh /opt/oathkeeper/

# expose oathkeeper proxy, not API
EXPOSE 4455

RUN chown -R ory:ory /opt/oathkeeper

CMD ["/opt/oathkeeper/start.sh"]

# install app
WORKDIR /app
ENV NODE_ENV production
COPY tsconfig.json package.json yarn.lock .meshrc.yml logger.ts server.ts /app/
COPY handlers /app/handlers
COPY .mesh logger.ts /app/.mesh/
RUN chown -R node:node /app
USER node
RUN yarn install && yarn cache clean

# switch back to root for s6 init
# hadolint ignore=DL3002
USER root
