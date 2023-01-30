#!/bin/bash -e

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

if [ -d /exastro ]; then    # Exastro IT Automation exists
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

##############################################################################
# Certificate

EXASTRO_ITA_DOMAIN=exastro-it-automation.local
CERTIFICATE_FILE=${EXASTRO_ITA_DOMAIN}.crt
PRIVATE_KEY_FILE=${EXASTRO_ITA_DOMAIN}.key
CSR_FILE=${EXASTRO_ITA_DOMAIN}.csr

if [ -e /exastro ]; then
  cd /etc/pki/tls/certs/
  echo "subjectAltName=DNS:${EXASTRO_ITA_DOMAIN}" > san.txt

  openssl genrsa 2048 > ${PRIVATE_KEY_FILE}
  openssl req -new -sha256 -key ${PRIVATE_KEY_FILE} -out ${CSR_FILE} -subj "/CN=${EXASTRO_ITA_DOMAIN}"
  openssl x509 -days 3650 -req -signkey ${PRIVATE_KEY_FILE} -extfile san.txt < ${CSR_FILE} > ${CERTIFICATE_FILE}

  rm -f ${CSR_FILE}
  rm -f san.txt
fi

# Execute command
exec "$@"
