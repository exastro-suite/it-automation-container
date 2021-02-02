#!/bin/bash -ex

##############################################################################
# Check required environment variables

for VAR in EXASTRO_ITA_VER EXASTRO_ITA_BASE_IMAGE EXASTRO_ITA_LANG; do
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
db_root_password:db_root_password
db_name:db_name
db_username:db_username
db_password:db_password
ita_base:yes
material:no
createparam:yes
hostgroup:yes
ansible_driver:yes
cobbler_driver:no
terraform_driver:no
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
