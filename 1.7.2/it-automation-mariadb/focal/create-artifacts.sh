#!/bin/bash -ux

##############################################################################
# Constants

declare -A EXASTRO_ITA_LANG_TABLE=(
    ["en"]="en_US"
    ["ja"]="ja_JP"
)


##############################################################################
# Install essential packages

apt-get update
apt-get install -y curl


##############################################################################
# Create workspace directory

WORKSPACE_DIR=/workspace
mkdir -p "${WORKSPACE_DIR}"


##############################################################################
# Download and unpack installer

curl -OL https://github.com/exastro-suite/it-automation/releases/download/v${EXASTRO_ITA_VER}/exastro-it-automation-${EXASTRO_ITA_VER}.tar.gz
tar zxvf exastro-it-automation-${EXASTRO_ITA_VER}.tar.gz

INSTALLER_DIR="${WORKSPACE_DIR}/it-automation-${EXASTRO_ITA_VER}"


##############################################################################
# Create artifacts directory

ARTIFACTS_DIR="${WORKSPACE_DIR}/artifacts"
mkdir -p "${ARTIFACTS_DIR}"


##############################################################################
# Copy MariaDB option file to the option file directory

MARIADB_OPTION_FILE_DIR="${ARTIFACTS_DIR}/etc/mysql/mariadb.conf.d"
mkdir -p "${MARIADB_OPTION_FILE_DIR}"
cp "${INSTALLER_DIR}/ita_install_package/ext_files_for_CentOS8.x/etc_my.cnf.d/server.cnf" "${MARIADB_OPTION_FILE_DIR}/50-server.cnf"

# Create symbolic link for log directory
MARIADB_LOG_DIR="${ARTIFACTS_DIR}/var/log/mariadb"
mkdir -p "$(dirname ${MARIADB_LOG_DIR})"
ln -s /var/log/mysql "${MARIADB_LOG_DIR}"


##############################################################################
# Copy SQL files to the docker entrypoint initdb directory

# Constants
SRC_SQL_FILES=(
    "${INSTALLER_DIR}/ita_install_package/install_scripts/sql/create-db-and-user_for_MySQL.sql"
    "${INSTALLER_DIR}/ita_install_package/ITA/ita-sqlscripts/${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}_mysql_ita_model-a.sql"
    "${INSTALLER_DIR}/ita_install_package/ITA/ita-sqlscripts/${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}_mysql_ita_model-m.sql"
    "${INSTALLER_DIR}/ita_install_package/ITA/ita-sqlscripts/${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}_mysql_ita_model-n.sql"
    "${INSTALLER_DIR}/ita_install_package/ITA/ita-sqlscripts/${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}_mysql_ita_model-n2.sql"
    "${INSTALLER_DIR}/ita_install_package/ITA/ita-sqlscripts/${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}_mysql_ita_model-n3.sql"
    "${INSTALLER_DIR}/ita_install_package/ITA/ita-sqlscripts/${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}_mysql_ita_model-c.sql"
    "${INSTALLER_DIR}/ita_install_package/ITA/ita-sqlscripts/${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}_mysql_ita_model-m2.sql"
)

DST_SQL_DIR="${ARTIFACTS_DIR}/docker-entrypoint-initdb.d"

# Ensure destination directory exists
mkdir -p "${DST_SQL_DIR}"

# Copy SQL files
for INDEX in "${!SRC_SQL_FILES[@]}"
do
    # Constants
    SRC_SQL_FILE="${SRC_SQL_FILES[$INDEX]}"
    DST_SQL_FILE="${DST_SQL_DIR}/$(printf %02d $INDEX)-$(basename $SRC_SQL_FILE)"

    # Copy SQL file
    cp "${SRC_SQL_FILE}" "${DST_SQL_FILE}"

    # Modify SQL file to set the install directory
    sed -i -e "s:%%%%%ITA_DIRECTORY%%%%%:${EXASTRO_ITA_INSTALL_DIR}:g" "${DST_SQL_FILE}"

    # Modify SQL file with "create-db-and-user_for_MySQL.sql" specific replacement
    if [ "$(basename $SRC_SQL_FILE)" = "create-db-and-user_for_MySQL.sql" ]; then
        sed -i \
            -e "s/ITA_DB/$EXASTRO_ITA_DB_NAME/g" \
            -e "s/ITA_USER/$EXASTRO_ITA_DB_USERNAME/g" \
            -e "s/ITA_PASSWD/$EXASTRO_ITA_DB_PASSWORD/g" \
            -e "s/^CREATE DATABASE /ALTER DATABASE /g" \
            "${DST_SQL_FILE}"
    fi
done
