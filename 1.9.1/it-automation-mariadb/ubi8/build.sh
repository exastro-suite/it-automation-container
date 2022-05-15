#!/bin/bash -ex

##############################################################################
# Check required environment variables

REQUIRED_ENV_VARS=(
    EXASTRO_ITA_VER
    EXASTRO_ITA_LANG
    EXASTRO_ITA_INSTALLER_URL
    EXASTRO_ITA_UNPACK_BASE_DIR
    EXASTRO_ITA_UNPACK_DIR
)

for VAR in "${REQUIRED_ENV_VARS[@]}"; do
    if [ -v ${VAR} ]; then
        echo "${VAR}=${!VAR}"
    else
        echo "Required environment variable $VAR is not defined."
        exit 1
    fi
done


##############################################################################
# Tables

declare -A EXASTRO_ITA_LANG_TABLE=(
    ["en"]="en_US"
    ["ja"]="ja_JP"
)

declare -A EXASTRO_ITA_SYSTEM_LOCALE_TABLE=(
    ["en"]="C.UTF-8"
    ["ja"]="ja_JP.UTF-8"
)

declare -A EXASTRO_ITA_SYSTEM_TIMEZONE_TABLE=(
    ["en"]="UTC"
    ["ja"]="Asia/Tokyo"
)


##############################################################################
# Update all installed packages

dnf update -y


##############################################################################
# DNF repository

cat << 'EOS' > /etc/yum.repos.d/centos8.repo
[baseos]
name=AlmaLinux $releasever - BaseOS
mirrorlist=https://mirrors.almalinux.org/mirrorlist/$releasever/baseos
# baseurl=https://repo.almalinux.org/almalinux/$releasever/BaseOS/$basearch/os/
gpgcheck=0
enabled=0

[appstream]
name=AlmaLinux $releasever - AppStream
mirrorlist=https://mirrors.almalinux.org/mirrorlist/$releasever/appstream
# baseurl=https://repo.almalinux.org/almalinux/$releasever/AppStream/$basearch/os/
gpgcheck=0
enabled=0
EOS


##############################################################################
# dnf and repository configuration

dnf install -y dnf-plugins-core
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --disable epel epel-modular


##############################################################################
# Set system locale

if [[ ${EXASTRO_ITA_SYSTEM_LOCALE_TABLE[$EXASTRO_ITA_LANG]} != "C."* ]]; then
    dnf install -y glibc-locale-source
    
    /usr/bin/localedef \
        -i `echo -n "${EXASTRO_ITA_SYSTEM_LOCALE_TABLE[$EXASTRO_ITA_LANG]}" | cut --delimiter=. --fields=1` \
        -f `echo -n "${EXASTRO_ITA_SYSTEM_LOCALE_TABLE[$EXASTRO_ITA_LANG]}" | cut --delimiter=. --fields=2` \
        "${EXASTRO_ITA_SYSTEM_LOCALE_TABLE[$EXASTRO_ITA_LANG]}"
fi

localectl set-locale "LANG=${EXASTRO_ITA_SYSTEM_LOCALE_TABLE[$EXASTRO_ITA_LANG]}"


##############################################################################
# Set system timezone

timedatectl set-timezone "${EXASTRO_ITA_SYSTEM_TIMEZONE_TABLE[$EXASTRO_ITA_LANG]}"


##############################################################################
# Reinstall "langpacks-en" to repare the corrupted language packs that causes
# garbled file name of exported Excel files.

dnf -y --enablerepo=appstream reinstall langpacks-en


##############################################################################
# install common packages (installer requirements)

dnf install -y diffutils procps which openssl
dnf install -y --enablerepo=baseos expect


##############################################################################
# install required packages

dnf install -y rsyslog  # for writing /var/log/messages
dnf install -y hostname # apache ssl needs hostname command
dnf install -y --enablerepo=appstream telnet


##############################################################################
# install ansible related packages

# WORKAROUND
#   sshpass was removed from EPEL repository on May 2022.
#     https://bugzilla.redhat.com/show_bug.cgi?id=2020679
#     https://src.fedoraproject.org/rpms/sshpass/c/f185e1ffab660fbbbf866dcc833b9a918e202d09?branch=epel8
#
#   sshpass has been added from RHEL 8.6, but unfortunately UBI 8 has not yet.
#   So use sshpass provided by AlmaLinux.

#dnf install -y --enablerepo=epel sshpass
dnf install -y --enablerepo=appstream sshpass


##############################################################################
# install MariaDB related packages
#   see https://mariadb.com/ja/resources/blog/how-to-install-mariadb-on-rhel8-centos8/
#   note: MariaDB 10.6 requires libpmem

dnf install -y perl-DBI libaio libsepol lsof
dnf install -y rsync iproute # additional installation
dnf install -y --enablerepo=appstream boost-program-options libpmem


##############################################################################
# ITAインストール資材展開

# No.1 ITAのインストール資材を展開する
#   Nothin to do

# No.2 ITAのインストール資材を展開する
curl -SL ${EXASTRO_ITA_INSTALLER_URL} | tar -xzC ${EXASTRO_ITA_UNPACK_BASE_DIR}

# No.3 ITAのインストール資材を展開する
cd ${EXASTRO_ITA_UNPACK_DIR}
find ${EXASTRO_ITA_UNPACK_DIR} -type f | xargs -I{} sed -i -e "s:%%%%%ITA_DIRECTORY%%%%%:${EXASTRO_ITA_INSTALL_DIR}:g" {}


##############################################################################
# yum-utilsインストール

# No.4 【CentOS7、RHEL7の場合】yum-utilsをインストールする
#   Nothin to do


##############################################################################
# 共有ディレクトリ（DBファイル保存先）設定

# No.5 MariaDBのDBファイル保存先ディレクトリを作成する
#   Nothin to do

# No.6 共有ディレクトリを設定する
#   Nothin to do


##############################################################################
# MariaDBインストール
#  No need to initialize MariaDB database because of providing database
#  files via database volume. So some steps are skipped.

# No.7 MariaDBをインストールする
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
dnf clean all
dnf install -y MariaDB MariaDB-server

# No.8 MariaDBのDBファイルを外部ストレージに移動する。
#   Nothin to do

# No.9 MariaDBのDBファイルを外部ストレージに移動する。
#   Nothin to do

# No.10 MariaDBのDBファイルを外部ストレージに移動する。
#   Nothin to do

# No.11 MariaDBの自動起動設定と起動を行う
systemctl enable mariadb
systemctl start mariadb

# No.12 MariaDBのrootパスワードを設定する
#send_db_root_password="${EXASTRO_ITA_DB_ROOT_PASSWORD}"
#send_db_root_password=$(echo "$send_db_root_password"|sed -e 's/\\/\\\\\\\\/g')
#send_db_root_password=$(echo "$send_db_root_password"|sed -e 's/\$/\\\\\\$/g')
#send_db_root_password=$(echo "$send_db_root_password"|sed -e 's/"/\\\\\\"/g')
#send_db_root_password=$(echo "$send_db_root_password"|sed -e 's/\[/\\\\\\[/g')
#send_db_root_password=$(echo "$send_db_root_password"|sed -e 's/\t/\\011/g')
#
#expect -c "
#    set timeout -1
#    spawn mariadb-secure-installation
#    expect \"Enter current password for root \\(enter for none\\):\"
#    send \"\\r\"
#    expect { 
#        -re \"Switch to unix_socket authentication.* $\" {
#            send \"n\\r\"
#            expect -re \"Change the root password\\?.* $\"
#            send \"Y\\r\"
#        }
#        -re \"Set root password\\?.* $\" {
#            send \"Y\\r\"
#        }
#    }
#    expect \"New password:\"
#    send \""${send_db_root_password}\\r"\"
#    expect \"Re-enter new password:\"
#    send \""${send_db_root_password}\\r"\"
#    expect -re \"Remove anonymous users\\?.* $\"
#    send \"Y\\r\"
#    expect -re \"Disallow root login remotely\\?.* $\"
#    send \"Y\\r\"
#    expect -re \"Remove test database and access to it\\?.* $\"
#    send \"Y\\r\"
#    expect -re \"Reload privilege tables now\\?.* $\"
#    send \"Y\\r\"
#"

# No.13 MariaDBの設定ファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files_for_CentOS8.x/etc_my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf

# No.14 MariaDBを再起動する
#systemctl restart mariadb

# No.15 MariaDBに接続する
#   Nothin to do

# No.16 MariaDBのユーザを作成する
# No.17 ITA用DBを作成する
# No.18 ユーザの権限を設定する
#  Note: No need to initialize MariaDB database, because of providing database files via database volume.

#cat << EOS > /tmp/create-db-and-user_for_MySQL.sql
#CREATE USER 'ITA_USER' IDENTIFIED BY 'ITA_PASSWD';
#CREATE USER 'ITA_USER'@'localhost' IDENTIFIED BY 'ITA_PASSWD';
#CREATE DATABASE ITA_DB CHARACTER SET utf8;
#GRANT ALL ON ITA_DB.* TO 'ITA_USER'@'%' WITH GRANT OPTION;
#GRANT ALL ON ITA_DB.* TO 'ITA_USER'@'localhost' WITH GRANT OPTION;
#EOS
#
#sed -i -e "s/ITA_DB/${EXASTRO_ITA_DB_NAME}/g" /tmp/create-db-and-user_for_MySQL.sql
#sed -i -e "s/ITA_USER/${EXASTRO_ITA_DB_USERNAME}/g" /tmp/create-db-and-user_for_MySQL.sql
#sed -i -e "s/ITA_PASSWD/${EXASTRO_ITA_DB_PASSWORD}/g" /tmp/create-db-and-user_for_MySQL.sql
#
#mysql -uroot < /tmp/create-db-and-user_for_MySQL.sql
#
#rm -f /tmp/create-db-and-user_for_MySQL.sql

# No.19 MariaDBを抜ける
#   Nothin to do

# No.20 ita_baseのテーブルを作成する
#mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-a.sql

# No.21 createparamのテーブルを作成する
#mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-m.sql

# No.22 hostgroupのテーブルを作成する
#mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-n.sql

# No.23 ansible_driverのテーブルを作成する
#mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-c.sql

# No.24 ansible_driver（収集機能）のテーブルを作成する
#mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-m2.sql

# No.25 cobbler_driverのテーブルを作成する
# mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-d.sql

# No.26 terraform_driverのテーブルを作成する
#mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-o.sql

# No.27 cicd_for_iacのテーブルを作成する
#mysql -u ${EXASTRO_ITA_DB_USERNAME} -p${EXASTRO_ITA_DB_PASSWORD} -D ${EXASTRO_ITA_DB_NAME} < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/ITA/ita-sqlscripts/ja_JP_mysql_ita_model-p.sql


##############################################################################
# Create database volume directory and symbolic limks to dirs in volume

mkdir /exastro-database-volume

systemctl stop mariadb
rm -rf /var/lib/mysql
ln -s /exastro-database-volume/mysql /var/lib/mysql
