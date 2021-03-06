#!/bin/bash -x

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Run container

$BASE_DIR/stop-and-delete.sh

docker run \
    --name "${IMAGE_NAME}" \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    "${IMAGE_FULL_NAME}"
