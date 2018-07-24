FROM debian:stretch-slim

COPY build_module.sh /
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
