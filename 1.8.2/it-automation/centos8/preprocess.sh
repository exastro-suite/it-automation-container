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
# Download Exastro IT Automation Installer

curl -SL ${EXASTRO_ITA_INSTALLER_URL} | tar -xzC ${EXASTRO_ITA_UNPACK_BASE_DIR}


##############################################################################
# Create ita_answers.txt

cat << EOS > ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/ita_answers.txt
install_mode:Install_Online
ita_directory:/exastro
ita_language:${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}
linux_os:CentOS8
distro_mariadb:yes
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
cicd_for_iac:no
ita_domain:exastro-it-automation.local
certificate_path:
private_key_path:
EOS


##############################################################################
# Update all installed packages

dnf update -y


##############################################################################
# dnf and repository configuration

dnf install -y dnf-plugins-core
dnf config-manager --enable powertools


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
# install common packages (installer requirements)

dnf install -y diffutils procps which openssl


##############################################################################
# install required packages

dnf install -y rsyslog  # for writing /var/log/messages
dnf install -y hostname # apache ssl needs hostname command


##############################################################################
# Python interpreter warning issue (container only)
#   see https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html

find ${EXASTRO_ITA_UNPACK_BASE_DIR} | grep -E "/ansible.cfg$" | xargs sed -i -E 's/^\[defaults\]$/[defaults\]\ninterpreter_python=auto_silent/'
