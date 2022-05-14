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
# Constants

# for SSL certificate
EXASTRO_ITA_DOMAIN=exastro-it-automation.local
CERTIFICATE_FILE=${EXASTRO_ITA_DOMAIN}.crt
PRIVATE_KEY_FILE=${EXASTRO_ITA_DOMAIN}.key
CSR_FILE=${EXASTRO_ITA_DOMAIN}.csr


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

dnf install -y --enablerepo=epel sshpass


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
# Apacheインストール

# No.5 Apacheをインストールする
dnf install -y httpd mod_ssl

# No.6 Apacheの自動起動設定を行う
systemctl enable httpd


##############################################################################
# PHPインストール

# No.7 PHPをインストールする
dnf install -y php php-bcmath php-cli php-ldap php-mbstring php-mysqlnd php-pear php-pecl-zip php-process php-snmp php-xml zip telnet mailx unzip php-json php-gd python3 php-devel libyaml make sudo crontabs libyaml-devel

# No.8 PEARライブラリをインストールする
pear install ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files/pear/HTML_AJAX-0.5.8.tgz

# No.9 HTML_AJAX-betaの設定を行う
ln -s /usr/share/pear-data/HTML_AJAX/js /usr/share/pear/HTML/js

# No.10 php-yamlをインストールする
pecl channel-update pecl.php.net
echo "" | pecl install YAML

# No.11 PhpSpreadsheet(v1.8.0)をインストールする
mkdir -p /usr/share/php/vendor

# No.12 PhpSpreadsheet(v1.8.0)をインストールする
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin
/usr/bin/composer.phar require "phpoffice/phpspreadsheet":"1.18.0"
mv vendor /usr/share/php/


##############################################################################
# PHPの設定

# No.13 【CentOS7、RHEL7の場合】php.iniを設定する
#   Nothin to do

# No.14 【CentOS8、CentOS Stream8、RHEL8の場合】php.iniを設定する
cp -pf ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files_for_CentOS8.x/etc/php.ini /etc/

# No.15 【CentOS8、CentOS Stream8、RHEL8の場合】www.confを設定する
cp -pf ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files_for_CentOS8.x/etc_php-fpm.d/www.conf /etc/php-fpm.d/


##############################################################################
# sudoersファイル変更

# No.16 sudo設定ファイル作成
cat << EOS > /etc/sudoers.d/it-automation
daemon ALL=(ALL) NOPASSWD:ALL
apache ALL=(ALL) NOPASSWD:ALL
EOS

# No.17 sudo設定ファイルの権限変更
chmod 440 /etc/sudoers.d/it-automation

# No.18 sudoersファイル変更
#   Nothing to do


##############################################################################
# ITAインストール

# No.19 インストール先ディレクトリ作成
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/

# No.20 ITA資材配置
cp -rp ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-contents/ita-root/ ${EXASTRO_ITA_INSTALL_DIR}/

# No.21 ITA設定ファイル配置
mkdir -p ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/
cp -rp ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-confs/* ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/

# No.22 セッション用ディレクトリ作成
mkdir -m 777 ${EXASTRO_ITA_INSTALL_DIR}/ita_sessions

# No.23 data_relay_storageディレクトリ作成
mkdir ${EXASTRO_ITA_INSTALL_DIR}/data_relay_storage

# No.24 ITAで使用するディレクトリ作成
while read line
do
  mkdir -p ${EXASTRO_ITA_INSTALL_DIR}${line};
done < ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/list/create_dir_list.txt

# No.25 権限を変更する(755)
while read line
do
  chmod 755 ${EXASTRO_ITA_INSTALL_DIR}${line};
done < ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/list/755_list.txt

# No.26 権限を変更する(777)
while read line
do
  chmod 777 ${EXASTRO_ITA_INSTALL_DIR}${line};
done < ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/list/777_list.txt

# No.27 ta_baseのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_base ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.28 createparamのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_createparam ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.29 hostgroupのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_hostgroup ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.30 ansible_driverのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_ansible-driver ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.31 cobbler_driverのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_cobbler-driver ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.31 terraform_driverのリリースファイルを配置する (Oops, duplicated number 31 !!)
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_terraform-driver ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.32 cicd_for_iacのリリースファイルを配置する
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ITA/ita-releasefiles/ita_cicd ${EXASTRO_ITA_INSTALL_DIR}/ita-root/libs/release/.

# No.33 MariaDB接続情報設定
echo -ne "mysql:dbname=ita_db;host=${EXASTRO_ITA_DB_SERVICE_NAME}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' > ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_connection_string.txt

# No.34 MariaDBのユーザ情報設定
echo -ne "${EXASTRO_ITA_DB_USERNAME}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' > ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_username.txt

# No.35 MariaDBのパスワード情報設定
echo -ne "${EXASTRO_ITA_DB_PASSWORD}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]' > ${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_password.txt


##############################################################################
# 共有ディレクトリ設定

# No.36 共有ディレクトリを設定する
#   Nothing to do


##############################################################################
# Apacheの設定

# No.37 /etc/hostsの設定
#   Nothing to do.
#   To add entry to /etc/hosts, execute "docker run" command with the option "--add-host".
#   ex. 
#     docker run --add-host=exastro-it-automation;127.0.0.1 [IMAGENAME]

# No.38 サーバ証明書と秘密鍵を作成する
#   Nothing to do.
#   Certificate and key pairs are created in docker-entrypoint.sh on starting the container.

# No.39 【CentOS7、RHEL7の場合】Apacheのconfファイル配置
#   Nothing to do

# No.40 【CentOS8、CentOS Stream8、RHEL8の場合】Apacheのconfファイル配置
cp -p ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/ext_files_for_CentOS8.x/etc_httpd_conf.d/vhosts_exastro-it-automation.conf /etc/httpd/conf.d/

# No.41 Apacheのconfファイル修正
sed -i -e "s:%%%%%ITA_DIRECTORY%%%%%:${EXASTRO_ITA_INSTALL_DIR}:g" /etc/httpd/conf.d/vhosts_exastro-it-automation.conf
sed -i -e "s:%%%%%ITA_DOMAIN%%%%%:${EXASTRO_ITA_DOMAIN}:g"         /etc/httpd/conf.d/vhosts_exastro-it-automation.conf
sed -i -e "s:%%%%%CERTIFICATE_FILE%%%%%:${CERTIFICATE_FILE}:g"     /etc/httpd/conf.d/vhosts_exastro-it-automation.conf
sed -i -e "s:%%%%%PRIVATE_KEY_FILE%%%%%:${PRIVATE_KEY_FILE}:g"     /etc/httpd/conf.d/vhosts_exastro-it-automation.conf

# No.42 Apacheの再起動
#   Nothing to do


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

