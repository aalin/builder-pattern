FROM node:11.12.0-alpine

ENV NODE_ENV=production

RUN apk update && apk add git

WORKDIR /app

ADD app.tar /app
RUN npm install
RUN apk del git && rm -rf /var/cache/apk/*

ENV PORT 80
EXPOSE $PORT

CMD ["node", "start-app.js"]
