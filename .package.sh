#!/bin/bash

set -e

echo "${ID_RSA}" > /root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa

# rm -rf ~/.npm
# ln -s /npm_cache ~/.npm

npm install

rm -rf /root/.ssh

npm run build:ci

tar cvvf /app.tar dist/ start-app.js package.json package-lock.json
