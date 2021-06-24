##############################################################################
# Constants

# Exastro IT Automation
export EXASTRO_ITA_VER="$(basename $(dirname $(dirname $(cd $(dirname $0); pwd))))"
export EXASTRO_ITA_LANG="${EXASTRO_ITA_LANG:-ja}"
export EXASTRO_ITA_INSTALL_DIR="${EXASTRO_ITA_INSTALL_DIR:-/exastro}"

# Database
export EXASTRO_ITA_DB_HOST=${EXASTRO_ITA_DB_HOST:-localhost}
export EXASTRO_ITA_DB_PORT=${EXASTRO_ITA_DB_PORT:-3306}
export EXASTRO_ITA_DB_NAME="${EXASTRO_ITA_DB_NAME:-ita_db}"
export EXASTRO_ITA_DB_ROOT_PASSWORD="${EXASTRO_ITA_DB_ROOT_PASSWORD:-ita_db_root_password}"
export EXASTRO_ITA_DB_USERNAME="${EXASTRO_ITA_DB_USERNAME:-ita_db_user}"
export EXASTRO_ITA_DB_PASSWORD="${EXASTRO_ITA_DB_PASSWORD:-ita_db_password}"

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
echo "Exastro IT Automation"
echo "    EXASTRO_ITA_VER=${EXASTRO_ITA_VER}"
echo "    EXASTRO_ITA_LANG=${EXASTRO_ITA_LANG}"
echo "    EXASTRO_ITA_INSTALL_DIR=${EXASTRO_ITA_INSTALL_DIR}"
echo "Database"
echo "    EXASTRO_ITA_DB_HOST=${EXASTRO_ITA_DB_HOST}"
echo "    EXASTRO_ITA_DB_PORT=${EXASTRO_ITA_DB_PORT}"
echo "    EXASTRO_ITA_DB_NAME=${EXASTRO_ITA_DB_NAME}"
echo "    EXASTRO_ITA_DB_ROOT_PASSWORD=${EXASTRO_ITA_DB_ROOT_PASSWORD}"
echo "    EXASTRO_ITA_DB_USERNAME=${EXASTRO_ITA_DB_USERNAME}"
echo "    EXASTRO_ITA_DB_PASSWORD=${EXASTRO_ITA_DB_PASSWORD}"
echo "Distro"
echo "    DISTRO_SYMBOL=${DISTRO_SYMBOL}"
echo "Image"
echo "    IMAGE_NAME=${IMAGE_NAME}"
echo "    IMAGE_HOST_AND_PATH=${IMAGE_HOST_AND_PATH}"
echo "    IMAGE_FULL_NAME=${IMAGE_FULL_NAME}"
echo "Image"
echo "    BUILDER_CONTAINER_NAME=${BUILDER_CONTAINER_NAME}"
echo "==========================================="
