FROM ubuntu:22.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y zip wget automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev \
    zlib1g-dev make g++ tmux git jq curl libncursesw5 libtool autoconf llvm libnuma-dev xz-utils zstd

WORKDIR /cardano-node

## Download latest cardano-cli, cardano-node tx-submit-service version static build

RUN wget -O cardano-9_1_1-aarch64-static-musl-ghc_966.tar.zst \
https://github.com/armada-alliance/cardano-node-binaries/blob/main/static-binaries/cardano-9_1_1-aarch64-static-musl-ghc_966.tar.zst?raw=true \
&& tar -I zstd -xvf cardano-9_1_1-aarch64-static-musl-ghc_966.tar.zst


## Install libsodium (needed for ScheduledBlocks.py)
WORKDIR /build/libsodium
RUN git clone https://github.com/input-output-hk/libsodium
RUN cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && ./configure && make && make install

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y curl wget zip netbase jq libnuma-dev lsof bc python3-pip git && \
    rm -rf /var/lib/apt/lists/*

## Copy Libsodium refs from builder image
COPY --from=builder /usr/local/lib /usr/local/lib

## Create node folders
WORKDIR /home/cardano
WORKDIR /home/cardano/.local/bin
WORKDIR /home/cardano/pi-pool/files
WORKDIR /home/cardano/pi-pool/scripts
WORKDIR /home/cardano/pi-pool/logs
WORKDIR /home/cardano/pi-pool/.keys
WORKDIR /home/cardano/git
WORKDIR /home/cardano/tmp

COPY --from=builder /cardano-node/cardano-9_1_1-aarch64-static-musl-ghc_966/* /home/cardano/.local/bin/

WORKDIR /home/cardano/pi-pool/scripts
COPY /files/run.sh /home/cardano/pi-pool/scripts
RUN git clone https://github.com/asnakep/poolLeaderLogs.git
RUN pip install -r /home/cardano/pi-pool/scripts/poolLeaderLogs/pip_requirements.txt

## Download gLiveView from original source
RUN wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env \
    && wget https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
RUN chmod +x env
RUN chmod +x gLiveView.sh

ENV PATH="/home/cardano/.local/bin:$PATH"

HEALTHCHECK --interval=10s --timeout=60s --start-period=300s --retries=3 CMD curl -f http://localhost:12798/metrics || exit 1

STOPSIGNAL SIGINT

COPY /files/tx-submit-service /home/cardano/.local/bin
COPY /files/run.sh /

CMD ["/run.sh"]