#!/bin/sh

set -e

ALPINE_VER="3.8"
MKROOTFS="/tmp/alpine-make-rootfs"
BUILD_TAR="/tmp/docker/alpine-rootfs-${ALPINE_VER}.tar.gz"
DOCKER_ROOT=$(dirname $BUILD_TAR)
POST_INSTALL="./post-install.sh"

mkdir $DOCKER_ROOT

# Download rootfs builder and verify it.
wget https://github.com/alpinelinux/alpine-make-rootfs/raw/af6880d17404e9811592092f0f8eb60959869ef5/alpine-make-rootfs -O ${MKROOTFS}
echo "c93db7105060fb4227eeaaf9a98555308913090f71ece86d28eee8a376ab439f  ${MKROOTFS}" | sha256sum -c -
chmod +x ${MKROOTFS}

sudo ${MKROOTFS} --mirror-uri http://dl-cdn.alpinelinux.org/alpine/ \
	--branch "v${ALPINE_VER}" \
	--packages 'ssl_client ca-certificates' \
	--script-chroot \
	${BUILD_TAR} \
	${POST_INSTALL}

cat <<DOCKERFILE > /tmp/docker/Dockerfile
FROM scratch
USER worker
ADD $(basename ${BUILD_TAR}) /
CMD ["/bin/sh"]
DOCKERFILE

cd $DOCKER_ROOT
docker build --no-cache -t skwashd/alpine:3.8 .
cd -
