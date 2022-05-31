FROM node:18-alpine

WORKDIR /app
ENV NODE_ENV production

COPY src package.json yarn.lock /app/
RUN chown -R node:node /app

USER node

RUN yarn install && yarn cache clean

EXPOSE 4000
CMD ["node", "app.js", "--port", "4000"]