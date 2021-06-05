#!/bin/bash -ex

##############################################################################
# Remove DB connection information (except password)
# It will be created on at first startup.
# Keep Default password in the file so that it should not be in environment variable.

rm -f "${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_connection_string.txt"
rm -f "${EXASTRO_ITA_INSTALL_DIR}/ita-root/confs/commonconfs/db_username.txt"
