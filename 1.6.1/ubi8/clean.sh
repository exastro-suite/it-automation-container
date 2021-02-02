#!/bin/bash -ex

##############################################################################
# Constants

EXASTRO_ITA_CONTAINER_NAME=it-automation-build


##############################################################################
# Clean

docker stop ${EXASTRO_ITA_CONTAINER_NAME}
docker rm ${EXASTRO_ITA_CONTAINER_NAME}
