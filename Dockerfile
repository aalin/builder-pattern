FROM node:11.12.0-alpine

ENV NODE_ENV=production

RUN apk update && apk add git

ADD server.tar /app
RUN find /app
WORKDIR /app/packages/server

RUN npm install && apk del git && rm -rf /var/cache/apk/*

ENV PORT 80
EXPOSE $PORT

ADD app.tar /app

CMD ["node", "start-app.js"]
