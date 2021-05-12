#!/bin/bash -x

##############################################################################
# Load variables

source $(cd $(dirname $0); pwd)/vars.sh

##############################################################################
# Run container

$(cd $(dirname $0); pwd)/stop.sh
docker run --name test-ita --privileged --add-host=exastro-it-automation:127.0.0.1 -d -p 8080:80 -p 10443:443 ${EXASTRO_ITA_IMAGE_NAME}
