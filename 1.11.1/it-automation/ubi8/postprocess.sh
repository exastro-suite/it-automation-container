#!/bin/bash -ex

##############################################################################
# Move, link and archive persistent directories

# file volume content path
declare -a EXASTRO_FILE_VOLUME_CONTENT_PATHS=(
    "data_relay_storage/symphony"
    "data_relay_storage/conductor"
    "data_relay_storage/ansible_driver"
    "ita_sessions"
    "ita-root/temp"
    "ita-root/uploadfiles"
    "ita-root/webroot/uploadfiles"
    "ita-root/webroot/menus/sheets"
    "ita-root/webroot/menus/users"
    "ita-root/webconfs/sheets"
    "ita-root/webconfs/users"
)


# database volume content path
declare -a EXASTRO_DATABASE_VOLUME_CONTENT_PATHS=(
    "mysql"
)


# move, link and archive
move_and_link_and_archive() {
    local SRC_BASE_DIR="$1"; shift
    local VOLUME_PATH="$1"; shift
    local RELATIVE_PATHS=($@)
    
    for RELATIVE_PATH in ${RELATIVE_PATHS[@]}; do
        local MOVE_SRC_PATH=${SRC_BASE_DIR}/${RELATIVE_PATH}
        local MOVE_DST_PATH=`dirname ${VOLUME_PATH}/${RELATIVE_PATH}`

        echo "move \"${MOVE_SRC_PATH}\" to \"${MOVE_DST_PATH}\""
        install --directory --mode=777 ${MOVE_DST_PATH}   # Alternative to mkdir
        mv ${MOVE_SRC_PATH} ${MOVE_DST_PATH}

        local LN_SRC_PATH=${VOLUME_PATH}/${RELATIVE_PATH}
        local LN_DST_PATH=${SRC_BASE_DIR}/${RELATIVE_PATH}

        echo "create symbolic link from \"${LN_SRC_PATH}\" to \"${LN_DST_PATH}\""
        ln -s ${LN_SRC_PATH} ${LN_DST_PATH}
    done

    local MARKER_FILE_PATH=${VOLUME_PATH}/.initialized

    echo "create marker file \"${MARKER_FILE_PATH}\""
    touch ${MARKER_FILE_PATH}

    local ARCHIVE_FILE_PATH="/exastro-initial-volume-archive/`basename ${VOLUME_PATH}`.tar.gz"

    echo "create archive file \"${ARCHIVE_FILE_PATH}\""
    install --directory --mode=755 `dirname ${ARCHIVE_FILE_PATH}`   # Alternative to mkdir
    tar zcvf ${ARCHIVE_FILE_PATH} -C ${VOLUME_PATH} ./
}

# ansible python verup
dnf install -y python3.12
update-alternatives --set python /usr/bin/python3.12
pip3.12 install --upgrade ansible

# stop services
systemctl stop httpd
systemctl stop mariadb

# move, link and archive
move_and_link_and_archive "/exastro" "/exastro-file-volume" "${EXASTRO_FILE_VOLUME_CONTENT_PATHS[@]}"
move_and_link_and_archive "/var/lib" "/exastro-database-volume" "${EXASTRO_DATABASE_VOLUME_CONTENT_PATHS[@]}"

# Certificate delete
rm -f /etc/pki/tls/certs/exastro-it-automation.local.crt
rm -f /etc/pki/tls/certs/exastro-it-automation.local.key
