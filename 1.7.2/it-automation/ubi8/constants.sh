##############################################################################
# Constants

# Exastro IT Automation
export EXASTRO_ITA_VER="$(basename $(dirname $(dirname $(cd $(dirname $0); pwd))))"
export EXASTRO_ITA_LANG="${EXASTRO_ITA_LANG:-ja}"

# Distro
export DISTRO_SYMBOL="$(basename $(cd $(dirname $0); pwd))"

# Image
export IMAGE_NAME="$(basename $(dirname $(cd $(dirname $0); pwd)))"
export IMAGE_HOST_AND_PATH="${IMAGE_HOST_AND_PATH:-}"
export IMAGE_FULL_NAME="${IMAGE_HOST_AND_PATH}${IMAGE_NAME}:${EXASTRO_ITA_VER}-${DISTRO_SYMBOL}-${EXASTRO_ITA_LANG}"

# Builder container
export BUILDER_CONTAINER_NAME="${IMAGE_NAME}-builder"


##############################################################################
# Print constants

echo "== CONSTANTS =============================="
echo "EXASTRO_ITA_VER=${EXASTRO_ITA_VER}"
echo "EXASTRO_ITA_LANG=${EXASTRO_ITA_LANG}"
echo "DISTRO_SYMBOL=${DISTRO_SYMBOL}"
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "IMAGE_HOST_AND_PATH=${IMAGE_HOST_AND_PATH}"
echo "IMAGE_FULL_NAME=${IMAGE_FULL_NAME}"
echo "BUILDER_CONTAINER_NAME=${BUILDER_CONTAINER_NAME}"
echo "==========================================="
