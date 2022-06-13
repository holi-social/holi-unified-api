FROM node:18-alpine

# s6 for running ory oathkeeper proxy in the same container
ARG S6_OVERLAY_VERSION=3.1.0.1
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
ENTRYPOINT ["/init"]

# install oathkeeper
#RUN addgroup -S ory; \
#    adduser -S ory -G ory -D -H -s /bin/nologin
RUN apk --no-cache --update-cache --upgrade --latest add ca-certificates=20211220-r0
RUN sh <(wget -c https://raw.githubusercontent.com/ory/meta/master/install.sh -O -) -d -b /opt/oathkeeper oathkeeper v0.38.25-beta.1

# set up oathkeeper as background daemon
ADD oathkeeper/s6 /etc/services.d/oathkeeper
RUN chown -R node:node /etc/services.d/oathkeeper/*

# copy oathkeeper config
COPY oathkeeper/config.yaml oathkeeper/rules.yaml oathkeeper/jwks.json /opt/oathkeeper/

# expose oathkeeper proxy, not API
EXPOSE 4455

# install app
WORKDIR /app
ENV NODE_ENV production

COPY src package.json yarn.lock /app/
RUN chown -R node:node /app

USER node

RUN yarn install && yarn cache clean
CMD ["node", "app.js", "--port", "4000"]