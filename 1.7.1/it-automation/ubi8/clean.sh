#!/bin/bash -ex

##############################################################################
# Load variables

source $(cd $(dirname $0); pwd)/vars.sh


##############################################################################
# Clean

docker stop ${EXASTRO_ITA_CONTAINER_NAME}
docker rm ${EXASTRO_ITA_CONTAINER_NAME}
