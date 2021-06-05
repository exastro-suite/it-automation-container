#!/bin/bash -xu

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Stop and delete container

docker stop ${IMAGE_NAME}
docker rm ${IMAGE_NAME}
