#!/bin/bash -e

##############################################################################
# ROT13 encoder

encode_base64_rot13() {
    local TEXT="$1"
    local OUTPUT_FILE_PATH="$2"

    echo -n "${TEXT}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' > "${OUTPUT_FILE_PATH}"
}


##############################################################################
# Initialize volume

initialize_volume() {
    local VOLUME_TYPE=$1
    local VOLUME_NAME=exastro-${VOLUME_TYPE}-volume
    local VOLUME_PATH=/${VOLUME_NAME}
    local MARKER_FILE_PATH=${VOLUME_PATH}/.initialized
    local ARCHIVE_FILE_PATH=/exastro-initial-volume-archive/${VOLUME_NAME}.tar.gz

    if [ ! -e "${MARKER_FILE_PATH}" ]; then
        echo "Volume is not initialized. (type=${VOLUME_TYPE})"

        if [ -f "$ARCHIVE_FILE_PATH" ]; then
            echo "Initialize volume. (type=${VOLUME_TYPE})"

            install --directory --mode=777 ${VOLUME_PATH}   # Alternative to mkdir
            tar zxvf ${ARCHIVE_FILE_PATH} -C ${VOLUME_PATH}

            if [ $? -eq 0 ]; then
                echo "Volume initialization succeeded.  (type=${VOLUME_TYPE})"
                touch ${MARKER_FILE_PATH}
            else
                echo "Volume initialization failed.  (type=${VOLUME_TYPE})"
            fi
        fi
    else
        echo "Volume is already initialized. (type=${VOLUME_TYPE})"
    fi
}


##############################################################################
# Main

echo "entry point parameters ... $@"

if [ -d "${EXASTRO_ITA_INSTALL_DIR}" ]; then
    # Initialize DB datasource name
    EXASTRO_ITA_DB_DSN_FILE="${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_connection_string.txt"
    if [ ! -f ${EXASTRO_ITA_DB_DSN_FILE} ]; then
        EXASTRO_ITA_DB_DSN="mysql:dbname=${EXASTRO_ITA_DB_NAME};host=${EXASTRO_ITA_DB_HOST};port=${EXASTRO_ITA_DB_PORT}"
        encode_base64_rot13 "${EXASTRO_ITA_DB_DSN}" "${EXASTRO_ITA_DB_DSN_FILE}"
    fi
    
    # Initialize DB access user
    EXASTRO_ITA_DB_USERNAME_FILE="${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_username.txt"
    if [ ! -f ${EXASTRO_ITA_DB_USERNAME_FILE} ]; then
        encode_base64_rot13 "${EXASTRO_ITA_DB_USERNAME}" "${EXASTRO_ITA_DB_USERNAME_FILE}"
    fi
    
    # Initialize DB access password
    EXASTRO_ITA_DB_PASSWORD_FILE="${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_password.txt"
    if [ -v EXASTRO_ITA_DB_PASSWORD ]; then
        encode_base64_rot13 "${EXASTRO_ITA_DB_PASSWORD}" "${EXASTRO_ITA_DB_PASSWORD_FILE}"
    fi
    
    # Initialize file volume
    if [ ${EXASTRO_AUTO_FILE_VOLUME_INIT:-false} = "true" ]; then
        echo "Auto file volume initialization is enabled."
        initialize_volume "file"
    fi
    
    # Initialize database volume
    if [ ${EXASTRO_AUTO_DATABASE_VOLUME_INIT:-false} = "true" ]; then
        echo "Auto database volume initialization is enabled."
        initialize_volume "database"
    fi
fi

# Execute command
exec "$@"
