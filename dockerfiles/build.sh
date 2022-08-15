#!/usr/bin/env bash

set -x

## Configuration paramenters
CNVERSION="1.35.3"        			## Version of the cardano-node. (Note: Must match the version downloaded in the dockerbuild file)
CNCONT_NAME="armadaalliance"			## Define the name of your docker container


## Do not change the part here below
##----------------------------------

docker build -t ${CNCONT_NAME}/armada-cn:${CNVERSION} \
  -f armada-cn-arm64.dockerfile . \
  2>&1 \
  | tee /tmp/build.logs
