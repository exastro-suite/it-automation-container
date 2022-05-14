#!/bin/bash -ex

##############################################################################
# Download Exastro IT Automation Installer

curl -SL ${EXASTRO_ITA_INSTALLER_URL} | tar -xzC ${EXASTRO_ITA_UNPACK_BASE_DIR}


##############################################################################
# Update all installed packages

dnf update -y


##############################################################################
# Build
##############################################################################
# DNF repository (ubi8)

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
# dnf and repository configuration (ubi8)
dnf install -y dnf-plugins-core
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --disable epel epel-modular


##############################################################################
# install common packages (installer requirements) (ubi8)

dnf install -y diffutils procps which openssl
dnf install -y --enablerepo=baseos expect


##############################################################################
# install required packages (ubi8)

dnf install -y rsyslog  # for writing /var/log/messages
dnf install -y hostname
dnf install -y --enablerepo=appstream telnet


##############################################################################
# install ansible related packages (ubi8)

dnf install -y --enablerepo=epel sshpass


##############################################################################
# install MariaDB related packages (ubi8)
#   see https://mariadb.com/ja/resources/blog/how-to-install-mariadb-on-rhel8-centos8/
#   note: MariaDB 10.6 requires libpmem

dnf install -y perl-DBI libaio libsepol lsof
dnf install -y rsync iproute # additional installation
dnf install -y --enablerepo=appstream boost-program-options libpmem


##############################################################################
# Set system locale and system timezone
dnf install -y glibc-locale-source
/usr/bin/localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localectl set-locale LANG=ja_JP.UTF-8
timedatectl set-timezone Asia/Tokyo


##############################################################################
# Reinstall "langpacks-en" to repare the corrupted language packs that causes
# garbled file name of exported Excel files.
dnf -y --enablerepo=appstream reinstall langpacks-en


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
# MariaDBインストール

# No.5 MariaDBをインストールする
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
dnf clean all
dnf install -y MariaDB


##############################################################################
# PHPインストール

# No.6 PHPをインストールする
dnf install -y php php-bcmath php-cli php-ldap php-mbstring php-mysqlnd php-pear php-pecl-zip php-process php-snmp php-xml zip telnet mailx unzip php-json php-gd python3 php-devel libyaml make sudo crontabs libyaml-devel

# No.7 PEARライブラリをインストールする
pear install ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files/pear/HTML_AJAX-0.5.8.tgz

# No.8 HTML_AJAX-betaの設定を行う
ln -s /usr/share/pear-data/HTML_AJAX/js /usr/share/pear/HTML/js

# No.9 php-yamlをインストールする
pecl channel-update pecl.php.net
echo "" | pecl install YAML

# No.10 PhpSpreadsheet(v1.8.0)をインストールする
mkdir -p /usr/share/php/vendor

# No.11 PhpSpreadsheet(v1.8.0)をインストールする
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin
/usr/bin/composer.phar require "phpoffice/phpspreadsheet":"1.18.0"
mv vendor /usr/share/php/


##############################################################################
# PHPの設定

# No.12 【CentOS7、RHEL7の場合】php.iniを設定する
#   Nothin to do

# No.13 【CentOS8、CentOS Stream8、RHEL8の場合】php.iniを設定する
cp -pf ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files_for_CentOS8.x/etc/php.ini /etc/

# No.14 【CentOS8、CentOS Stream8、RHEL8の場合】www.confを設定する
cp -pf ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files_for_CentOS8.x/etc_php-fpm.d/www.conf /etc/php-fpm.d/


##############################################################################
# ITAインストール

# No.15 インストール先ディレクトリ作成
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/

# No.16 共有用ディレクトリの作成
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/data_relay_storage
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/temp
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/uploadfiles
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/webroot/uploadfiles
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/webroot/menus/sheets
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/webroot/menus/users
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/webconfs/sheets
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/webconfs/users
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/repositorys

# No.17 共有ディレクトリを設定する
#   Nothin to do

# No.18 ITA資材配置
cp -rp ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-contents/ita-root/ ${EXASTRO_ITA_INSTALL_DIR}/

# No.19 ITA設定ファイル配置
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/
cp -rp ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-confs/* ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/

# ● セッション用ディレクトリ作成
#mkdir -m 777 ${EXASTRO_ITA_INSTALL_DIR}/ita_sessions

# ● data_relay_storageディレクトリ作成
#mkdir ${EXASTRO_ITA_INSTALL_DIR}/data_relay_storage

# No.20 ITAで使用するディレクトリ作成
while read line
do
  mkdir -p ${EXASTRO_ITA_INSTALL_DIR}${line};
done < ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/list/create_dir_list.txt

# No.21 権限を変更する(755)
while read line
do
  chmod 755 ${EXASTRO_ITA_INSTALL_DIR}${line};
done < ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/list/755_list.txt

# No.22 権限を変更する(777)
while read line
do
  chmod 777 ${EXASTRO_ITA_INSTALL_DIR}${line};
done < ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/list/777_list.txt

# No.23 ta_baseのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_base ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.24 createparamのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_createparam ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.25 hostgroupのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_hostgroup ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.26 ansible_driverのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_ansible-driver ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.27 cobbler_driverのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_cobbler-driver ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.27 terraform_driverのリリースファイルを配置する (Oops, duplicated number 27 !!)
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_terraform-driver ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.28 cicd_for_iacのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_cicd ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.29 MariaDB接続情報設定
echo -ne "mysql:dbname=ita_db;host=${EXASTRO_ITA_DB_SERVICE_NAME}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' > ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_connection_string.txt

# No.30 MariaDBのユーザ情報設定
echo -ne "${EXASTRO_ITA_DB_USERNAME}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' > ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_username.txt

# No.31 MariaDBのパスワード情報設定
echo -ne "${EXASTRO_ITA_DB_PASSWORD}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' > ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_password.txt


##############################################################################
# ITAのbackyard設定

# No.32 backyardの設定ファイルのリンクを作成する
ln -s ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/backyardconfs/ita_env /etc/sysconfig/ita_env

# No.33 ita_baseのbackyard処理のサービスファイルをコピーする
while read line
do
  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/base_service_list.txt

# No.34 createparamのbackyard処理のサービスファイルをコピーする
while read line
do
  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/createparam_service_list.txt

# No.35 hostgroupのbackyard処理のサービスファイルをコピーする
while read line
do
  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/hostgroup_service_list.txt

# No.36 ansible_driverのbackyard処理のサービスファイルをコピーする
while read line
do
  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/ansible_service_list.txt

# No.37 ansible_driver（収集機能）のbackyard処理のサービスファイルをコピーする
while read line
do
  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/createparam2_service_list.txt

# No.38 cobbler_driverのbackyard処理のサービスファイルをコピーする
#while read line
#do
#  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
#done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/cobbler_service_list.txt

# No.39 terraform_driverのbackyard処理のサービスファイルをコピーする
while read line
do
  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/terraform_service_list.txt

# No.40 cicd_for_iacのbackyard処理のサービスファイルをコピーする
while read line
do
  cp -p ${EXASTRO_ITA_INSTALL_DIR}${line}.service /usr/lib/systemd/system/.
done < ${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}/ita_install_package/install_scripts/list/cicd_service_list.txt

# No.41 サービスの常駐設定を行う
ls -1 /usr/lib/systemd/system/. | grep ky_ | xargs systemctl enable

# No.42 サービスの起動を行う
ls -1 /usr/lib/systemd/system/. | grep ky_ | xargs systemctl start


##############################################################################
# ITAのcron設定

# No.43 cron設定を行う
cat << EOS > /var/spool/cron/root
01 00 * * * su - -c ${EXASTRO_ITA_INSTALL_DIR}/ita-root/backyards/common/ky_execinstance_dataautoclean-workflow.sh
02 00 * * * su - -c ${EXASTRO_ITA_INSTALL_DIR}/ita-root/backyards/common/ky_file_autoclean-workflow.sh
EOS

##############################################################################
# Install git

dnf install -y git


##############################################################################
# Create file volume directory and symbolic limks to dirs in volume

mkdir /exastro-file-volume

SHARED_DIRS=(
    data_relay_storage/ansible_driver
    data_relay_storage/conductor
    data_relay_storage/symphony
    ita_sessions
    ita-root/temp
    ita-root/uploadfiles
    ita-root/webconfs/sheets
    ita-root/webconfs/users
    ita-root/webroot/menus/sheets
    ita-root/webroot/menus/users
    ita-root/webroot/uploadfiles
)

for SHARED_DIR in ${SHARED_DIRS[@]}; do
    rm -rf ${EXASTRO_ITA_INSTALL_DIR}/${SHARED_DIR}
    ln -s /exastro-file-volume/${SHARED_DIR} ${EXASTRO_ITA_INSTALL_DIR}/${SHARED_DIR}
done
