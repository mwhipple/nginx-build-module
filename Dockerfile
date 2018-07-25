FROM debian:stretch-slim

# This script is downloaded from http://hg.nginx.org/pkg-oss/raw-file/default/build_module.sh
ADD vendor/build_module.sh /

WORKDIR /

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
       wget \
       sudo \
       mercurial \
       git \
       ssh \
       ca-certificates \
       make \
       devscripts \
       file \
       lsb-release \
       gcc \
       fakeroot \
       build-essential \
       debhelper \
       quilt \
       libssl-dev \
       libpcre3-dev \
       zlib1g-dev \
       unzip \
    && chmod a+x build_module.sh

ENTRYPOINT ["/build_module.sh"]
