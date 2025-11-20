FROM europe-north1-docker.pkg.dev/holi-shared/docker-hub-remote/node:24-slim

# install all dependencies for later steps
RUN apt-get -y -qq update && apt-get install -y --no-install-recommends xz-utils ca-certificates curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# shell sanity with pipes (https://github.com/hadolint/hadolint/wiki/DL4006)
# needed for installation of s6
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# s6 for running ory oathkeeper proxy in the same container
ARG S6_OVERLAY_VERSION=3.2.0.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
ENTRYPOINT ["/init"]

# start oathkeeper only when node is running (but we still need to wait until node opened the port, see oathkeeper/start.sh)
ENV S6_CMD_WAIT_FOR_SERVICES=1

# install oathkeeper
RUN addgroup --system ory; adduser --system ory --group --disabled-login --no-create-home
# hadolint ignore=SC3001
ADD https://raw.githubusercontent.com/ory/meta/master/install.sh /tmp
RUN sh /tmp/install.sh -d -b /opt/oathkeeper oathkeeper v0.40.9

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
ENV NODE_ENV=production
COPY tsconfig.json package.json yarn.lock .meshrc.yml .yarnrc.yml logger.ts utils.ts instrument.ts server.ts /app/
COPY handlers /app/handlers
COPY .mesh logger.ts /app/.mesh/
RUN chown -R node:node /app && corepack enable
USER node

# FIXME: use existing yarn cache to use consistent dependencies as in whole CI pipeline
RUN yarn install --immutable --check-cache && yarn cache clean

# switch back to root for s6 init
# hadolint ignore=DL3002
USER root
