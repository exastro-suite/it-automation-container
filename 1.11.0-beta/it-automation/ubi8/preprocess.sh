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
# dnf (yum) and repository configuration

dnf install -y dnf-plugins-core yum-utils   # "dnf config-manager" and "yum-config-manager"
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

dnf install -y --enablerepo=appstream sshpass


##############################################################################
# install MariaDB related packages
#   see https://mariadb.com/ja/resources/blog/how-to-install-mariadb-on-rhel8-centos8/
#   note: MariaDB 10.6 requires libpmem

dnf install -y perl-DBI libaio libsepol lsof
dnf install -y rsync iproute # additional installation
dnf install -y --enablerepo=appstream boost-program-options libpmem


##############################################################################
# Download Exastro IT Automation Installer

curl -SL ${EXASTRO_ITA_INSTALLER_URL} | tar -xzC ${EXASTRO_ITA_UNPACK_BASE_DIR}

# Python interpreter warning issue (container only)
#   see https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html
find ${EXASTRO_ITA_UNPACK_DIR} | grep -E "/ansible.cfg$" | xargs sed -i -E 's/^\[defaults\]$/[defaults\]\ninterpreter_python=auto_silent/'


##############################################################################
# Create ita_answers.txt

cat << EOS > ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/ita_answers.txt
install_mode:Install_Online
ita_directory:/exastro
ita_language:${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}
linux_os:RHEL8
distro_mariadb:no
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
cicd_for_iac:yes
terraformcli_driver:yes
ita_domain:exastro-it-automation.local
certificate_path:
private_key_path:
EOS


##############################################################################
# modify scripts (bin/ita_builder_core.sh)
#   for DNF repository check

sed -i \
    -E 's/ (create_repo_check .+) >>/ echo "----- SKIP \1 -----" >>/' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh

sed -i \
    -E 's/ cloud_repo_setting$/ echo "----- SKIP cloud_repo_setting -----"/' \
    ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/bin/ita_builder_core.sh
