#!/bin/bash -ex

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Clean

docker stop ${BUILDER_CONTAINER_NAME}
docker rm ${BUILDER_CONTAINER_NAME}
