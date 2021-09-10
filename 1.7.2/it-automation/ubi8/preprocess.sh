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
    ["en"]="C.utf-8"
    ["ja"]="ja_JP.UTF-8"
)

declare -A EXASTRO_ITA_SYSTEM_TIMEZONE_TABLE=(
    ["en"]="UTC"
    ["ja"]="Asia/Tokyo"
)


##############################################################################
# Download Exastro IT Automation Installer

curl -SL ${EXASTRO_ITA_INSTALLER_URL} | tar -xzC ${EXASTRO_ITA_UNPACK_BASE_DIR}


##############################################################################
# Create ita_answers.txt

cat << EOS > ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/ita_answers.txt
install_mode:Install_Online
ita_directory:/exastro
ita_language:${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}
linux_os:RHEL8
db_root_password:ita_root_password
db_name:ita_db
db_username:ita_db_user
db_password:ita_db_password
ita_base:yes
material:no
createparam:yes
hostgroup:yes
ansible_driver:yes
cobbler_driver:no
terraform_driver:yes
ita_domain:exastro-it-automation.local
certificate_path:
private_key_path:
EOS


##############################################################################
# Update all installed packages

dnf update -y


##############################################################################
# DNF repository

cat << 'EOS' > /etc/yum.repos.d/centos8.repo
[baseos]
name=CentOS Linux $releasever - BaseOS
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=BaseOS&infra=$infra
#baseurl=http://mirror.centos.org/$contentdir/$releasever/BaseOS/$basearch/os/
gpgcheck=0
enabled=0

[appstream]
name=CentOS Linux $releasever - AppStream
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=AppStream&infra=$infra
#baseurl=http://mirror.centos.org/$contentdir/$releasever/AppStream/$basearch/os/
gpgcheck=0
enabled=0
EOS


##############################################################################
# dnf and repository configuration

dnf install -y dnf-plugins-core
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --disable epel epel-modular


##############################################################################
# Set system locale and system timezone

#dnf -y --enablerepo=appstream install langpacks-"$EXASTRO_ITA_LANG"
#localectl set-locale "LANG=${EXASTRO_ITA_SYSTEM_LOCALE_TABLE[$EXASTRO_ITA_LANG]}"

timedatectl set-timezone "${EXASTRO_ITA_SYSTEM_TIMEZONE_TABLE[$EXASTRO_ITA_LANG]}"


##############################################################################
# install common packages (installer requirements)

dnf install -y diffutils procps openssl
dnf install -y --enablerepo=baseos expect


##############################################################################
# install web related packages

dnf install -y hostname # apache ssl needs hostname command
dnf install -y --enablerepo=appstream telnet


##############################################################################
# Python interpreter warning issue (container only)
#   see https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html

find ${EXASTRO_ITA_UNPACK_BASE_DIR} | grep -E "/ansible.cfg$" | xargs sed -i -E 's/^\[defaults\]$/[defaults\]\ninterpreter_python=auto_silent/'


##############################################################################
# install ainsible related packages

dnf install -y --enablerepo=epel sshpass


##############################################################################
# install MariaDB
#   see https://mariadb.com/ja/resources/blog/how-to-install-mariadb-on-rhel8-centos8/
#   note: MariaDB 10.6 requires libpmem

curl -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
./mariadb_repo_setup

dnf install -y perl-DBI libaio libsepol lsof
dnf install -y rsync iproute # additional installation
dnf install -y --enablerepo=appstream boost-program-options libpmem
dnf install -y --repo=mariadb-main MariaDB-server
systemctl enable mariadb
systemctl start mariadb


##############################################################################
# modify scripts (bin/ita_builder_core.sh)
#   for DNF repository check

sed -i \
    -E 's/ (create_repo_check .+) >>/ echo "----- SKIP \1 -----" >>/' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh

sed -i \
    -E 's/ cloud_repo_setting$/ echo "----- SKIP cloud_repo_setting -----"/' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh


##############################################################################
# modify scripts (bin/ita_builder_core.sh)
#   for MariaDB

# ORIGINAL:
#     if [ RHEL7 or CentOS7 ]
#         if [ already installed ]
#             // skip install official MariaDB, then configure (** EXPECT COMMAND MAY NOT WORK !! **)
#         else
#             // install official MariaDB, then configure
#    
#     if [ RHEL8 or CentOS8 ]
#         if [ already installed ]
#             // skip install distro's MariaDB, then configure
#         else
#             // installdistro's MariaDB, then configure
#
#              |
#              |
#              V
#
# MODIFIED:
#     if [ true ]
#         if [ false ]
#             // DON'T CARE
#         else
#             // COME HERE !!!
#    
#     if [ false ]
#         // DON'T CARE


# fall in configuring official MariaDB
sed -i \
    -E 's/\[ "\$LINUX_OS" == "RHEL7" -o "\$LINUX_OS" == "CentOS7" \]/"true"/' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh

# skip configuring distribution's MariaDB
# note: This will also rewrite the condition for "local installation". But actually
#       no impact on container building because remote installation is always executed.
sed -i \
    -E 's/\[ "\$LINUX_OS" == "RHEL8" -o "\$LINUX_OS" == "CentOS8" \]/"false"/' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh

# fall through to MariaDB installation (by installation check failure)
sed -i \
    -E 's/yum list installed mariadb-server/yum list installed XXXXXXXXXXXXXX/' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh

# skip configuring DNF repository of MariaDB (already configured in this script).
sed -i \
    -E 's/mariadb_repository /#mariadb_repository /' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh

