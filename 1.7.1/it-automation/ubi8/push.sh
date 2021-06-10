#!/bin/bash -xe

##############################################################################
# Load variables

source $(cd $(dirname $0); pwd)/vars.sh


##############################################################################
# Push container image

docker push "$EXASTRO_ITA_IMAGE_NAME"
