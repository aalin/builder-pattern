#!/bin/bash

set -e

[ -z "$IMAGE_NAME" ] && echo "Need to set IMAGE_NAME" && exit 1
[ -z "$BUILD_NUMBER" ] && echo "Need to set BUILD_NUMBER" && exit 1

GIT_REVISION=$(git rev-parse --short HEAD)
GIT_BRANCH=${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}
PACKAGE_JSON_VERSION=$(grep -m1 version package.json | awk -F: '{ print $2 }' | sed 's/[ ",]//g')

SERVICE_NAME=demo
SERVICE_BRANCH=${GIT_BRANCH##*/}
BUILDER_NAME=${SERVICE_NAME}__builder
VERSION=v${PACKAGE_JSON_VERSION}-${BUILD_NUMBER}__${APP_BRANCH}
BUILD_TAG=${IMAGE_NAME}:${VERSION}
BUILD_TAG=${IMAGE_NAME}:${VERSION}
LATEST_TAG=${IMAGE_NAME}:latest

NPM_CACHE_VOLUME=$(docker volume create --name=npm_cache_volume)
OUT_DIR=$(mktemp -d)

SSH_KEY_PATH=${SSH_KEY_PATH:-$HOME/.ssh/id_rsa}
echo "Using ssh key: $SSH_KEY_PATH"

printHeader () {
  local str=`echo -e "\x1b[48;5;129m \x1b[48;5;45m \x1b[48;5;118m \x1b[48;5;220m \x1b[48;5;160m \x1b[0m"`

  if which figlet > /dev/null; then
    figlet -f future $* | sed "s/^/${str} /g"
  else
    echo "${str} $*"
  fi
}

finish () {
  [[ -f builder.cid ]] && docker rm -f "$(cat builder.cid)" || true

  rm -f ./*.cid
  rm -rf "${OUT_DIR}"
}
trap finish EXIT

buildBuildImage () {
  printHeader "Building build image"
  docker build -f Dockerfile.builder -t "${BUILDER_NAME}" .
}

buildApp () {
  printHeader "Building application"

  docker run \
    -e "APP_VERSION=${PACKAGE_JSON_VERSION}" \
    -e "GIT_REVISION=${GIT_REVISION}" \
    -e "BUILD_NUMBER=${BUILD_NUMBER}" \
    -v "${npm_cache_volume}:/root/.npm" \
    -e "ID_RSA=${ID_RSA}" \
    --cidfile=builder.cid \
    -t "${BUILDER_NAME}"
}

buildAppImage () {
  printHeader "Building application image"

  docker cp "$(cat builder.cid)":/app.tar "${OUT_DIR}/app.tar"

  cp Dockerfile "${OUT_DIR}"

  docker build -t "${BUILD_TAG}" "${OUT_DIR}"
  docker tag "${BUILD_TAG}" "${LATEST_TAG}"

  echo -e "\033[32mSuccessfully built ${BUILD_TAG}, also tagged as ${LATEST_TAG}\033[0m"
  echo "IMAGE_NAME=${BUILD_TAG}" > build.properties
  local service_image=${BUILD_TAG##*/}
  echo -e "SERVICE_NAME=${SERVICE_NAME}\nSERVICE_BRANCH=${SERVICE_BRANCH}\nSERVICE_IMAGE=${service_image}" > deploy.properties
}

buildBuildImage
buildApp
buildAppImage
