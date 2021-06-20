#!/bin/bash -xe

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Build image

DOCKER_BUILDKIT=1 docker build \
    --tag ${IMAGE_FULL_NAME} \
    --no-cache \
    --progress=plain \
    --build-arg HTTP_PROXY \
    --build-arg http_proxy \
    --build-arg HTTPS_PROXY \
    --build-arg https_proxy \
    --build-arg NO_PROXY \
    --build-arg no_proxy \
    --build-arg EXASTRO_ITA_VER \
    --build-arg EXASTRO_ITA_LANG \
    --build-arg EXASTRO_ITA_INSTALL_DIR \
    --build-arg EXASTRO_ITA_DB_NAME \
    --build-arg EXASTRO_ITA_DB_USERNAME \
    --build-arg EXASTRO_ITA_DB_PASSWORD \
    .
