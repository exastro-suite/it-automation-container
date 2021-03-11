#!/bin/bash -x

EXASTRO_ITA_VER=1.6.3
EXASTRO_ITA_LANG=${1:-ja}

docker run --privileged --add-host=exastro-it-automation:127.0.0.1 -d -p 8080:80 -p 10443:443 it-automation:${EXASTRO_ITA_VER}-ubi8-${EXASTRO_ITA_LANG}
