#!/bin/bash -xu

##############################################################################
# Load constants

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/constants.sh


##############################################################################
# Run container

$BASE_DIR/stop-and-delete.sh

docker run \
    --name ${IMAGE_NAME} \
    -it \
    --env MARIADB_ROOT_PASSWORD=${EXASTRO_ITA_DB_ROOT_PASSWORD} \
    --env MARIADB_DATABASE=${EXASTRO_ITA_DB_NAME} \
    ${IMAGE_FULL_NAME}
