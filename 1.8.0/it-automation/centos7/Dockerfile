FROM centos:8

ARG EXASTRO_ITA_VER

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
