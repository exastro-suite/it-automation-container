#!/bin/bash -xe

##############################################################################
# Load variables

source $(cd $(dirname $0); pwd)/vars.sh


##############################################################################
# Constants

EXASTRO_ITA_UNPACK_BASE_DIR=/root
EXASTRO_ITA_UNPACK_DIR=${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}


##############################################################################
# Build image

docker build \
    --tag ${EXASTRO_ITA_IMAGE_NAME} \
    --build-arg EXASTRO_ITA_VER \
    ./

docker run \
    --detach \
    --privileged \
    --env EXASTRO_ITA_VER \
    --env EXASTRO_ITA_LANG \
    --name ${EXASTRO_ITA_CONTAINER_NAME} \
    ${EXASTRO_ITA_IMAGE_NAME}

sleep 10

docker exec \
    --tty \
    ${EXASTRO_ITA_CONTAINER_NAME} \
    /root/preprocess.sh

docker exec \
    --tty \
    --workdir=${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts \
    ${EXASTRO_ITA_CONTAINER_NAME} \
    /bin/sh -x ita_installer.sh

docker exec \
    --tty \
    ${EXASTRO_ITA_CONTAINER_NAME} \
    /root/postprocess.sh

docker stop \
    ${EXASTRO_ITA_CONTAINER_NAME}

docker commit \
    ${EXASTRO_ITA_CONTAINER_NAME} \
    ${EXASTRO_ITA_IMAGE_NAME}
