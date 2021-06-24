#!/bin/bash -xe

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Build image

docker build \
    --tag ${IMAGE_FULL_NAME} \
    --build-arg EXASTRO_ITA_VER \
    ./

docker run \
    --detach \
    --privileged \
    --env EXASTRO_ITA_VER \
    --env EXASTRO_ITA_LANG \
    --name ${BUILDER_CONTAINER_NAME} \
    ${IMAGE_FULL_NAME}

sleep 10

docker exec \
    --tty \
    --env EXASTRO_ITA_INSTALLER_URL \
    --env EXASTRO_ITA_UNPACK_BASE_DIR \
    --env EXASTRO_ITA_UNPACK_DIR \
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
