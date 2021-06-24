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
export EXASTRO_ITA_DB_USERNAME="${EXASTRO_ITA_DB_USERNAME:-ita_db_user}"
export EXASTRO_ITA_DB_PASSWORD="${EXASTRO_ITA_DB_PASSWORD:-ita_db_password}"

# Distro
export DISTRO_SYMBOL="$(basename $(cd $(dirname $0); pwd))"

# Image
export IMAGE_NAME="$(basename $(dirname $(cd $(dirname $0); pwd)))"
export IMAGE_HOST_AND_PATH="${IMAGE_HOST_AND_PATH:-}"
export IMAGE_FULL_NAME="${IMAGE_HOST_AND_PATH}${IMAGE_NAME}:${EXASTRO_ITA_VER}-${DISTRO_SYMBOL}-${EXASTRO_ITA_LANG}"

# Builder container
export BUILDER_CONTAINER_NAME="${IMAGE_NAME}-${EXASTRO_ITA_VER}-${DISTRO_SYMBOL}-${EXASTRO_ITA_LANG}-builder"

# Preprocess
export EXASTRO_ITA_INSTALLER_URL=${EXASTRO_ITA_INSTALLER_URL:-https://github.com/exastro-suite/it-automation/releases/download/v${EXASTRO_ITA_VER}/exastro-it-automation-${EXASTRO_ITA_VER}.tar.gz}
export EXASTRO_ITA_UNPACK_BASE_DIR=${EXASTRO_ITA_UNPACK_BASE_DIR:-/root}
export EXASTRO_ITA_UNPACK_DIR_NAME=${EXASTRO_ITA_UNPACK_DIR_NAME:-it-automation-${EXASTRO_ITA_VER}}
export EXASTRO_ITA_UNPACK_DIR=${EXASTRO_ITA_UNPACK_BASE_DIR}/${EXASTRO_ITA_UNPACK_DIR_NAME}
