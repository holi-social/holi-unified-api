FROM node:18-alpine

# shell sanity with pipes (https://github.com/hadolint/hadolint/wiki/DL4006)
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# s6 for running ory oathkeeper proxy in the same container
ARG S6_OVERLAY_VERSION=3.1.0.1
RUN wget -c -q https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -O - | tar -xJpC /
RUN wget -c -q https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -O - | tar -xJpC /
ENTRYPOINT ["/init"]

# start oathkeeper only when node is running
ENV S6_CMD_WAIT_FOR_SERVICES=1

# install oathkeeper
RUN apk --no-cache --update-cache --upgrade --latest add ca-certificates=20211220-r0
# shellcheck disable=SC3001
RUN sh <(wget -c -q https://raw.githubusercontent.com/ory/meta/master/install.sh -O -) -d -b /opt/oathkeeper oathkeeper v0.38.25-beta.1

# set up oathkeeper as background daemon
COPY oathkeeper/s6/run oathkeeper/s6/finish /etc/services.d/oathkeeper/

# TODO https://github.com/just-containers/s6-overlay#dropping-privileges

# copy oathkeeper config
COPY oathkeeper/config.yaml oathkeeper/rules.yaml oathkeeper/jwks.json oathkeeper/start-cmd.sh /opt/oathkeeper/

# expose oathkeeper proxy, not API
EXPOSE 4455

# install app
WORKDIR /app
ENV NODE_ENV production

COPY src package.json yarn.lock /app/

RUN yarn install && yarn cache clean
#CMD ["node", "app.js", "--port", "4000"]
CMD ["/opt/oathkeeper/start-cmd.sh"]