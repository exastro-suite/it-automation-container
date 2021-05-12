#!/bin/bash -ex

##############################################################################
# Backup initial database

systemctl stop mariadb
tar zcvf /exastro/var_lib_mysql.tar.gz -C /var/lib/mysql/ .

