#!/bin/bash -ex

##############################################################################
# Check required environment variables

for VAR in EXASTRO_ITA_VER EXASTRO_ITA_LANG; do
    if [ ! -v $VAR ]; then
        echo "Required environment variable $VAR is not defined."
        exit 1
    fi
done


##############################################################################
# Variables

EXASTRO_ITA_UNPACK_BASE_DIR=/root
EXASTRO_ITA_UNPACK_DIR=${EXASTRO_ITA_UNPACK_BASE_DIR}/it-automation-${EXASTRO_ITA_VER}

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
# Set system locale and system timezone

dnf -y --enablerepo=appstream install langpacks-"$EXASTRO_ITA_LANG"
localectl set-locale "LANG=${EXASTRO_ITA_SYSTEM_LOCALE_TABLE[$EXASTRO_ITA_LANG]}"

timedatectl set-timezone "${EXASTRO_ITA_SYSTEM_TIMEZONE_TABLE[$EXASTRO_ITA_LANG]}"


##############################################################################
# install common packages (installer requirements)

dnf install -y openssl


##############################################################################
# Download Exastro IT Automation Installer

curl -SL https://github.com/exastro-suite/it-automation/releases/download/v${EXASTRO_ITA_VER}/exastro-it-automation-${EXASTRO_ITA_VER}.tar.gz | tar -xzC ${EXASTRO_ITA_UNPACK_BASE_DIR}


##############################################################################
# Create ita_answers.txt

cat << EOS > ${EXASTRO_ITA_UNPACK_DIR}/ita_install_package/install_scripts/ita_answers.txt
install_mode:Install_Online
ita_directory:/exastro
ita_language:${EXASTRO_ITA_LANG_TABLE[$EXASTRO_ITA_LANG]}
linux_os:CentOS8
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
# dnf and repository configuration

dnf install -y dnf-plugins-core
dnf config-manager --enable powertools


##############################################################################
# install common packages

dnf install -y diffutils procps # installer needs diff and ps


##############################################################################
# install web related packages

dnf install -y hostname # apache ssl needs hostname command


##############################################################################
# Python interpreter warning issue (container only)
#   see https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html

find ${EXASTRO_ITA_UNPACK_BASE_DIR} | grep -E "/ansible.cfg$" | xargs sed -i -E 's/^\[defaults\]$/[defaults\]\ninterpreter_python=auto_silent/'
