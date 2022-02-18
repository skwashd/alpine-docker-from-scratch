#!/bin/sh
#
# Copyright (c) 2018-2020 Dave Hall <skwashd@gmail.com>
# MIT Licensed, see LICENSE for more information.
#

set -ex

DOCKER_USERNAME="${DOCKER_USERNAME:-skwashd}"
ALPINE_VER="${ALPINE_VER:-latest-stable}"
PACKAGES="apk-tools ca-certificates ssl_client"

MKROOTFS="/tmp/alpine-make-rootfs"
BUILD_TAR="/tmp/docker/alpine-rootfs-${ALPINE_VER}.tar.gz"
DOCKER_ROOT=$(dirname $BUILD_TAR)
POST_INSTALL="./post-install.sh"

mkdir $DOCKER_ROOT

# Download rootfs builder and verify it.
wget https://raw.githubusercontent.com/alpinelinux/alpine-make-rootfs/v0.5.1/alpine-make-rootfs -O "$MKROOTFS"
echo "5413d0114d92abde279c9e2e65c9e8536e7eaca71f60e72e31bf13c7b5f16436  $MKROOTFS" | sha256sum -c -
chmod +x ${MKROOTFS}

sudo ${MKROOTFS} --mirror-uri http://dl-2.alpinelinux.org/alpine \
	--branch "${ALPINE_VER}" \
	--packages "$PACKAGES" \
	--script-chroot \
	"$BUILD_TAR" \
	"$POST_INSTALL"

cat <<DOCKERFILE > "${DOCKER_ROOT}/Dockerfile"
FROM scratch
USER worker
ADD $(basename $BUILD_TAR) /
CMD ["/bin/sh"]
DOCKERFILE

cd $DOCKER_ROOT
docker build --no-cache -t "${DOCKER_USERNAME}/alpine:${ALPINE_VER}" .
cd -

docker build  --build-arg BASE_IMAGE="${DOCKER_USERNAME}/alpine:${ALPINE_VER}" - <<'DOCKERFILE'
ARG BASE_IMAGE
FROM $BASE_IMAGE
ARG MS_TOKEN
USER root
RUN apk update && apk add curl && rm -rf /var/cache/apk/*
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin 
DOCKERFILE
