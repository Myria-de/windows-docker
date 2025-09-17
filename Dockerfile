# syntax=docker/dockerfile:1
# added qemu-system-modules-spice for spice server
FROM scratch AS build-amd64

COPY --from=qemux/qemu:7.12 / /
ARG TARGETARCH

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

RUN set -eu && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        bc \
        curl \
        7zip \
        wsdd2 \
        samba \
        xz-utils \
        wimtools \
        dos2unix \
        cabextract \
        genisoimage \
        qemu-system-modules-spice \
        libxml2-utils \
        libarchive-tools && \
    wget "https://github.com/gershnik/wsdd-native/releases/download/v1.21/wsddn_1.21_${TARGETARCH}.deb" -O /tmp/wsddn.deb -q && \
    dpkg -i /tmp/wsddn.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
COPY --chmod=755 ./src /run/
COPY --chmod=755 ./assets /run/assets

ADD --chmod=755 https://raw.githubusercontent.com/christgau/wsdd/refs/tags/v0.9/src/wsdd.py /usr/sbin/wsdd
ADD --chmod=664 https://github.com/qemus/virtiso-whql/releases/download/v1.9.47-0/virtio-win-1.9.47.tar.xz /var/drivers.txz

FROM dockurr/windows-arm:${VERSION_ARG} AS build-arm64
FROM build-${TARGETARCH}

ARG VERSION_ARG="0.00"
RUN echo "$VERSION_ARG" > /run/version

VOLUME /storage
EXPOSE 3389 8006

ENV RAM_SIZE "4G"
ENV CPU_CORES "2"
ENV DISK_SIZE "64G"
ENV VERSION "11"

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
