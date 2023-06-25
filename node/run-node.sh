#!/usr/bin/env bash

set -x

##Configuration for relay and block producing node
CNIMAGENAME="armadaalliance/armada-cn"                           ## Name of the Cardano docker image
CNVERSION="8.1.1"                                                ## Version of the cardano-node. It must match with the version of the docker image
CNNETWORK="preprod"                                              ## Use "mainnet" if connecting node to the mainnet
CNMODE="relay"                                                   ## Use "bp" if you configure the node as block production node
CNPORT="3001"                                                    ## Define the port of the node
CNPROMETHEUS_PORT="12799"                                        ## Define the port for the Prometheus metrics
CN_CONFIG_PATH="/home/julienterrier/Cardano-node-docker/node/files" ## Path to the folder where the Cardano config files are stored on the host system
CN_DB_PATH="/home/julienterrier/Cardano-node-docker/node/db"     ## Path to the folder where the Cardano database (blockchain) will be stored on the host system
CN_RTS_OPTS="+RTS -N2 -I0.1 -Iw3600 -A64m -AL128M -n4m -F1.1 -H3500M -O3500M -RTS"      ## RTS optimization parameters
CN_BF_ID=""                                                      ## Your blockfrost.io project ID (for ScheduledBlock script)
CN_POOL_ID=""                                                    ## Your stake pool ID (for ScheduledBlock script)
CN_POOL_TICKER=""                                                ## Your pool ticker (for ScheduledBlock script)
CN_VRF_SKEY_PATH=""                                              ## Name of the vrf.skey file. It must be located in the same directory as CN_KEY_PATH (for ScheduledBlock script)
CN_KEY_PATH=""                                                   ## Path to the folder where the OP certificate and keys are stored on the host system


##Do not edit/change section below!
##---------------------------------
docker run --detach \
    --name=cardano-node-${CNNETWORK}-${CNVERSION} \
    --restart=always \
    -p ${CNPORT}:${CNPORT} \
    -p ${CNPROMETHEUS_PORT}:12798 \
    -p 8090:8090 \
    -e NETWORK=${CNNETWORK} \
    -e NODE_MODE=${CNMODE} \
    -e PORT=${CNPORT} \
    -e CARDANO_RTS_OPTS="${CN_RTS_OPTS}" \
    -e BFID=${CN_BF_ID} \
    -e POOLID=${CN_POOL_ID} \
    -e POOLTICKER=${CN_POOL_TICKER} \
    -e SB_VRF_SKEY_PATH=${CN_VRF_SKEY_PATH} \
    -e CARDANO_NODE_SOCKET_PATH=/home/cardano/pi-pool/db/node.socket \
    -v ${CN_CONFIG_PATH}:/home/cardano/pi-pool/files  \
    -v ${CN_DB_PATH}:/home/cardano/pi-pool/db \
    -v ${CN_KEY_PATH}:/home/cardano/pi-pool/.keys \
    ${CNIMAGENAME}:${CNVERSION}
