#!/bin/bash -xe

##############################################################################
# Check required environment variables

for VAR in EXASTRO_ITA_VER EXASTRO_ITA_BASE_IMAGE EXASTRO_ITA_LANG EXASTRO_ITA_IMAGE_NAME; do
    if [ ! -v $VAR ]; then
        echo "Required environment variable $VAR is not defined."
        exit 1
    fi
done


##############################################################################
# Constants

EXASTRO_ITA_CONTAINER_NAME=it-automation-build
EXASTRO_ITA_UNPACK_BASE_DIR=/root
EXASTRO_ITA_UNPACK_DIR=${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}


##############################################################################
# Build image

docker build \
    --tag ${EXASTRO_ITA_IMAGE_NAME} \
    ./

docker run \
    --detach \
    --privileged \
    --env EXASTRO_ITA_VER \
    --env EXASTRO_ITA_LANG \
    --env EXASTRO_ITA_BASE_IMAGE \
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

docker stop \
    ${EXASTRO_ITA_CONTAINER_NAME}

docker commit \
    ${EXASTRO_ITA_CONTAINER_NAME} \
    ${EXASTRO_ITA_IMAGE_NAME}
