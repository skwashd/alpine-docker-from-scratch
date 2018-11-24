#!/bin/sh

set -e

ALPINE_VER="3.8"
PACKAGES="apk-tools ca-certificates ssl_client"


MKROOTFS="/tmp/alpine-make-rootfs"
BUILD_TAR="/tmp/docker/alpine-rootfs-${ALPINE_VER}.tar.gz"
DOCKER_ROOT=$(dirname $BUILD_TAR)
POST_INSTALL="./post-install.sh"

mkdir $DOCKER_ROOT
MS_ROOT="${DOCKER_ROOT}/../microscanner"
mkdir $MS_ROOT

# Download rootfs builder and verify it.
wget https://github.com/alpinelinux/alpine-make-rootfs/raw/af6880d17404e9811592092f0f8eb60959869ef5/alpine-make-rootfs -O "$MKROOTFS"
echo "c93db7105060fb4227eeaaf9a98555308913090f71ece86d28eee8a376ab439f  $MKROOTFS" | sha256sum -c -
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
docker build --no-cache -t skwashd/alpine:3.8 .
cd -

docker build --build-arg MS_TOKEN="${MS_TOKEN}" - <<'DOCKERFILE'
FROM skwashd/alpine:3.8
ARG MS_TOKEN
RUN wget https://get.aquasec.com/microscanner -O /home/worker/microscanner \
  && echo "72fd95ef5d343915c37ad487ba83da56e4d79d2f999cbdb2bfb1afda0d6bd7bb  /home/worker/microscanner" | sha256sum -c - \
  && chmod +x /home/worker/microscanner \
  && /home/worker/microscanner $MS_TOKEN
DOCKERFILE
