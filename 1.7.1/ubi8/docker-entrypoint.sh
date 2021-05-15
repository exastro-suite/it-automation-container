#!/bin/bash -e

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


echo "entry point parameters ... $@"

if [ ${EXASTRO_AUTO_FILE_VOLUME_INIT:-false} = "true" ]; then
    echo "Auto file volume initialization is enabled."
    initialize_volume "file"
fi

if [ ${EXASTRO_AUTO_DATABASE_VOLUME_INIT:-false} = "true" ]; then
    echo "Auto database volume initialization is enabled."
    initialize_volume "database"
fi

exec "$@"
