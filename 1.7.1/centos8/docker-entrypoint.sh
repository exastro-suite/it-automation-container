#!/bin/bash -e

echo "entry point parameters ... $@"

if [ "$1" = '/sbin/init' ]; then
    if [ ! -e "/var/lib/mysql/mysql" ]; then
        echo "Database not found."

        if [ -f "/exastro/var_lib_mysql.tar.gz" ]; then
            echo "Restore initial database."
            tar zxvf /exastro/var_lib_mysql.tar.gz -C /var/lib/mysql
        fi
    fi
fi

exec "$@"
