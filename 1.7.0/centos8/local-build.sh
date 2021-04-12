#!/bin/bash -ex

export EXASTRO_ITA_VER=1.7.0
export EXASTRO_ITA_LANG=${EXASTRO_ITA_LANG:-ja}
export EXASTRO_ITA_BASE_IMAGE=centos8
export EXASTRO_ITA_IMAGE_NAME=it-automation:${EXASTRO_ITA_VER}-${EXASTRO_ITA_BASE_IMAGE}-${EXASTRO_ITA_LANG}

BASE_DIR=$(cd $(dirname $0); pwd)
$BASE_DIR/build.sh
