#!/bin/bash -ex

##############################################################################
# Move, link and archive persistent directories

# file storage content path
declare -a EXASTRO_FILE_STORAGE_CONTENT_PATHS=(
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


# database storage content path
declare -a EXASTRO_DATABASE_STORAGE_CONTENT_PATHS=(
    "mysql"
)


# move, link and archive
move_and_link_and_archive() {
    local src_dir=$1
    shift

    local dst_dir=$1
    shift

    local relative_paths=($@)
    
    for relative_path in ${relative_paths[@]}; do
        move_src_path=${src_dir}/${relative_path}
        move_dst_path=`dirname ${dst_dir}/${relative_path}`

        echo "move \"$move_src_path\" to \"$move_dst_path\""
        # Alternative to mkdir
        install --directory --mode=777 $move_dst_path
        mv ${move_src_path} ${move_dst_path}

        ln_src_path=${dst_dir}/${relative_path}
        ln_dst_path=${src_dir}/${relative_path}

        echo "create symbolic link from \"$ln_src_path\" to \"$ln_dst_path\""
        ln -s ${ln_src_path} ${ln_dst_path}
    done

    marker_filep_path=${dst_dir}/.initialized

    echo "create marker file \"$marker_filep_path\""
    touch ${marker_filep_path}

    tar_gz_file_path="/root/`basename $dst_dir`.tar.gz"

    echo "create archive file \"$tar_gz_file_path\""
    tar zcvf ${tar_gz_file_path} -C ${dst_dir} ./
}

# stop services
systemctl stop httpd
systemctl stop mariadb

# move, link and archive
move_and_link_and_archive "/exastro" "/exastro_file_storage" "${EXASTRO_FILE_STORAGE_CONTENT_PATHS[@]}"
move_and_link_and_archive "/var/lib" "/exastro_database_storage" "${EXASTRO_DATABASE_STORAGE_CONTENT_PATHS[@]}"

rm -rf /exastro_file_storage
install --directory --mode=777 /exastro_file_storage

rm -rf /exastro_database_storage
install --directory --mode=777 /exastro_database_storage
