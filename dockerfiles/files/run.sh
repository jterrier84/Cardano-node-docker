#!/usr/bin/env bash

##Initialize env settings for gLiveView
sed -i 's+#CCLI="${HOME}/.cabal/bin/cardano-cli"+CCLI="/home/cardano/.local/bin/cardano-cli"+' env
sed -i 's+#CNODE_PORT=6000+CNODE_PORT=${PORT}+' env
sed -i 's+#CONFIG="${CNODE_HOME}/files/config.json"+CONFIG="/home/cardano/pi-pool/files/mainnet-config.json"+' env
sed -i 's+#SOCKET="${CNODE_HOME}/sockets/node0.socket"+SOCKET="/home/cardano/pi-pool/db/node.socket"+' env
sed -i 's+#TOPOLOGY="${CNODE_HOME}/files/topology.json"+TOPOLOGY="/home/cardano/pi-pool/files/mainnet-topology.json"+' env
sed -i 's+#LOG_DIR="${CNODE_HOME}/logs"+s+LOG_DIR="/home/cardano/pi-pool/logs"+' env
sed -i 's+#DB_DIR="${CNODE_HOME}/db"+DB_DIR="/home/cardano/pi-pool/db"+' env
sed -i 's+#UPDATE_CHECK="Y"+UPDATE_CHECK="N"+' env

##Initialize env settings for ScheduledBlocks
sed -i 's+BlockFrostId = ""+BlockFrostId = "'${BFID}'"+' ScheduledBlocks/ScheduledBlocks.py
sed -i 's+PoolId = ""+PoolId = "'${POOLID}'"+' ScheduledBlocks/ScheduledBlocks.py
sed -i 's+PoolTicker = ""+PoolTicker = "'${POOLTICKER}'"+' ScheduledBlocks/ScheduledBlocks.py
sed -i 's+<path_to>/vrf.skey+/home/cardano/pi-pool/.keys/'${SB_VRF_SKEY_PATH}'+' ScheduledBlocks/ScheduledBlocks.py

##Start cardano-node in relay mode
if [ "${NODE_MODE}" = "relay" ]; then

"cardano-node ${CARDANO_RTS_OPTS} run \
    --topology /home/cardano/pi-pool/files/${NETWORK}-topology.json \
    --config /home/cardano/pi-pool/files/${NETWORK}-config.json \
    --database-path /home/cardano/pi-pool/db \
    --socket-path /home/cardano/pi-pool/db/node.socket \
    --host-addr 0.0.0.0 \
    --port ${PORT}"

##Start cardano-node in block production mode
elif [ "${NODE_MODE}" = "bp" ]; then

"cardano-node ${CARDANO_RTS_OPTS} run \
    --topology /home/cardano/pi-pool/files/${NETWORK}-topology.json \
    --config /home/cardano/pi-pool/files/${NETWORK}-config.json \
    --database-path /home/cardano/pi-pool/db \
    --socket-path /home/cardano/pi-pool/db/node.socket \
    --host-addr 0.0.0.0 \
    --port ${PORT} \
    --shelley-kes-key /home/cardano/pi-pool/.keys/*.kes-*.skey \
    --shelley-vrf-key /home/cardano/pi-pool/.keys/*.vrf.skey \
    --shelley-operational-certificate /home/cardano/pi-pool/.keys/*.opcert"

fi
