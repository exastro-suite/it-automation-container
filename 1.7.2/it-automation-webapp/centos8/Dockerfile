FROM centos:8

ARG EXASTRO_ITA_VER
ARG EXASTRO_ITA_LANG
ARG EXASTRO_ITA_INSTALL_DIR
ARG EXASTRO_ITA_DB_USERNAME
ARG EXASTRO_ITA_DB_NAME
ARG EXASTRO_ITA_DB_HOST
ARG EXASTRO_ITA_DB_PORT
ARG EXASTRO_ITA_DB_USERNAME

ENV EXASTRO_ITA_VER=${EXASTRO_ITA_VER}
ENV EXASTRO_ITA_LANG=${EXASTRO_ITA_LANG}
ENV EXASTRO_ITA_INSTALL_DIR=${EXASTRO_ITA_INSTALL_DIR}
ENV EXASTRO_ITA_DB_NAME=${EXASTRO_ITA_DB_NAME}
ENV EXASTRO_ITA_DB_HOST=${EXASTRO_ITA_DB_HOST}
ENV EXASTRO_ITA_DB_PORT=${EXASTRO_ITA_DB_PORT}
ENV EXASTRO_ITA_DB_USERNAME=${EXASTRO_ITA_DB_USERNAME}

### Required OpenShift Labels
LABEL name="Exastro IT Automation" \
      vendor="NEC Corporation" \
      version="v${EXASTRO_ITA_VER}" \
      release="1" \
      summary="Exastro IT Automation container." \
      description="This container provides Exastro IT Automation service."

# Required Licenses
COPY licenses/ /licenses/

# Preprocess/Postprocess script
COPY preprocess.sh postprocess.sh /root/

# Entrypoint script
COPY docker-entrypoint.sh /

# Entrypoint and default parameters
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/sbin/init"]
