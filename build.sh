#!/bin/sh
#
# Copyright (c) 2018-2020 Dave Hall <skwashd@gmail.com>
# MIT Licensed, see LICENSE for more information.
#

set -ex

ALPINE_VER="${ALPINE_VER:-3.10}"
PACKAGES="apk-tools ca-certificates ssl_client"

MKROOTFS="/tmp/alpine-make-rootfs"
BUILD_TAR="/tmp/docker/alpine-rootfs-${ALPINE_VER}.tar.gz"
DOCKER_ROOT=$(dirname $BUILD_TAR)
POST_INSTALL="./post-install.sh"

mkdir $DOCKER_ROOT
MS_ROOT="${DOCKER_ROOT}/../microscanner"
mkdir $MS_ROOT

# Download rootfs builder and verify it.
wget https://raw.githubusercontent.com/alpinelinux/alpine-make-rootfs/v0.5.1/alpine-make-rootfs -O "$MKROOTFS"
echo "5413d0114d92abde279c9e2e65c9e8536e7eaca71f60e72e31bf13c7b5f16436  $MKROOTFS" | sha256sum -c -
chmod +x ${MKROOTFS}

sudo ${MKROOTFS} --mirror-uri http://dl-2.alpinelinux.org/alpine \
	--branch "v${ALPINE_VER}" \
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
docker build --no-cache -t "skwashd/alpine:${ALPINE_VER}" .
cd -

docker build  --build-arg BASE_IMAGE="skwashd/alpine:${ALPINE_VER}" --build-arg MS_TOKEN="${MS_TOKEN}" - <<'DOCKERFILE'
ARG BASE_IMAGE
FROM $BASE_IMAGE
ARG MS_TOKEN
RUN wget https://get.aquasec.com/microscanner -O /home/worker/microscanner \
  && echo "8e01415d364a4173c9917832c2e64485d93ac712a18611ed5099b75b6f44e3a5  /home/worker/microscanner" | sha256sum -c - \
  && chmod +x /home/worker/microscanner \
  && /home/worker/microscanner $MS_TOKEN
DOCKERFILE
