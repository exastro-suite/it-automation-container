#!/bin/bash -xe

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Push container image

docker push "$IMAGE_FULL_NAME"
