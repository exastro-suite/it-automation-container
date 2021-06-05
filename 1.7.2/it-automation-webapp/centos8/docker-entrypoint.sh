#!/bin/bash -e

##############################################################################
# Encode ROT13

encode_rot13() {
    local TEXT="$1"
    local OUTPUT_FILE_PATH="$2"

    echo -n "${TEXT}" | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' | base64 > "${OUTPUT_FILE_PATH}"
}


##############################################################################
# Main

EXASTRO_ITA_INSTALL_DIR=/exastro

EXASTRO_ITA_DB_DSN_FILE="${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_connection_string.txt"
if [ -f ${EXASTRO_ITA_DB_DSN_FILE} ]; then
    EXASTRO_ITA_DB_DSN="mysql:dbname=${EXASTRO_ITA_DB_NAME};host=${EXASTRO_ITA_DB_HOST};port=${EXASTRO_ITA_DB_PORT}"
    encode_rot13 "${EXASTRO_ITA_DB_DSN}" "${EXASTRO_ITA_DB_DSN_FILE}"
if

EXASTRO_ITA_DB_USERNAME_FILE="${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_username.txt"
if [ -f ${EXASTRO_ITA_DB_USERNAME_FILE} ]; then
    encode_rot13 "${EXASTRO_ITA_DB_USERNAME}" "${EXASTRO_ITA_DB_USERNAME_FILE}"
if

EXASTRO_ITA_DB_PASSWORD_FILE="${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_password.txt"
if [ -v EXASTRO_ITA_DB_PASSWORD ]; then
    encode_rot13 "${EXASTRO_ITA_DB_PASSWORD}" "${EXASTRO_ITA_DB_PASSWORD_FILE}"
if


# Execute command
exec "$@"
