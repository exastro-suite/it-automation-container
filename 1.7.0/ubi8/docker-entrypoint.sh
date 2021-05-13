#!/bin/bash -e

echo "entry point parameters ... $@"

if [ "$1" = '/sbin/init' ]; then
    if [ ! -e "/exastro_file_storage/.initialized" ]; then
        echo "File storage is not initialized."

        if [ -f "/root/exastro_file_storage.tar.gz" ]; then
            echo "Initialize file storage."
            # Alternative to mkdir
            install --directory --mode=777 /exastro_file_storage
            tar zxvf /root/exastro_file_storage.tar.gz -C /exastro_file_storage
        fi
    fi

    if [ ! -e "/exastro_database_storage/.initialized" ]; then
        echo "Database storage is not initialized."

        if [ -f "/root/exastro_database_storage.tar.gz" ]; then
            echo "Initialize database storage."
            # Alternative to mkdir
            install --directory --mode=777 /exastro_database_storage
            tar zxvf /root/exastro_database_storage.tar.gz -C /exastro_database_storage
        fi
    fi
fi

exec "$@"
