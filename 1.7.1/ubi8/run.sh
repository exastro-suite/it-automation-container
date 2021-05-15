#!/bin/bash -x

##############################################################################
# Load variables

BASE_DIR=$(cd $(dirname $0); pwd)
source $BASE_DIR/vars.sh

##############################################################################
# Run container

$BASE_DIR/stop.sh

VOLUME_OPTION=""
if [ "$1" = "-v" ]; then
    FILE_VOLUME_HOST_PATH=$BASE_DIR/tmp/exastro-file-volume
    mkdir -p -m 777 ${FILE_VOLUME_HOST_PATH}

    DATABASE_VOLUME_HOST_PATH=$BASE_DIR/tmp/exastro-database-volume
    mkdir -p -m 777 ${DATABASE_VOLUME_HOST_PATH}

    FILE_VOLUME_OPTION="--volume ${FILE_VOLUME_HOST_PATH}:/exastro-file-volume" --env EXASTRO_AUTO_FILE_VOLUME_INIT=true"
    DATABASE_VOLUME_OPTION="--volume ${DATABASE_VOLUME_HOST_PATH}:/exastro-database-volume" --env EXASTRO_AUTO_DATABASE_VOLUME_INIT=true"
fi

docker run \
    --name test-ita \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    ${FILE_VOLUME_OPTION} \
    ${DATABASE_VOLUME_OPTION} \
    ${EXASTRO_ITA_IMAGE_NAME}
