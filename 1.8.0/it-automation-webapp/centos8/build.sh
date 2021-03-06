#!/bin/bash -xe

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Constants

EXASTRO_ITA_UNPACK_BASE_DIR=/root
EXASTRO_ITA_UNPACK_DIR=${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}


##############################################################################
# Build image

docker build \
    --tag ${IMAGE_FULL_NAME} \
    --build-arg EXASTRO_ITA_VER \
    --build-arg EXASTRO_ITA_LANG \
    --build-arg EXASTRO_ITA_INSTALL_DIR \
    --build-arg EXASTRO_ITA_DB_USERNAME \
    --build-arg EXASTRO_ITA_DB_NAME \
    --build-arg EXASTRO_ITA_DB_HOST \
    --build-arg EXASTRO_ITA_DB_PORT \
    ./

docker run \
    --detach \
    --privileged \
    --name ${BUILDER_CONTAINER_NAME} \
    ${IMAGE_FULL_NAME}

sleep 10

docker exec \
    --tty \
    ${BUILDER_CONTAINER_NAME} \
    /root/preprocess.sh

docker exec \
    --tty \
    --workdir=${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts \
    ${BUILDER_CONTAINER_NAME} \
    /bin/sh -x ita_installer.sh

docker exec \
    --tty \
    ${BUILDER_CONTAINER_NAME} \
    /root/postprocess.sh

docker stop \
    ${BUILDER_CONTAINER_NAME}

docker commit \
    ${BUILDER_CONTAINER_NAME} \
    ${IMAGE_FULL_NAME}
