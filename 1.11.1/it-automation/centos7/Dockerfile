FROM centos:7

ARG EXASTRO_ITA_VER

### Required OpenShift Labels
LABEL name="Exastro IT Automation" \
      vendor="NEC Corporation" \
      version="v${EXASTRO_ITA_VER}" \
      release="1" \
      summary="Exastro IT Automation container." \
      description="This container provides Exastro IT Automation service."

# Update root CA
RUN --mount=type=secret,id=extra-root-ca \
if [ -f /run/secrets/extra-root-ca ]; then \
    cp /run/secrets/extra-root-ca /usr/share/pki/ca-trust-source/anchors/extra-root-ca.crt; \
    update-ca-trust; \
fi

# Required Licenses
COPY licenses/ /licenses/

# Preprocess/Postprocess script
COPY preprocess.sh postprocess.sh /root/

# Entrypoint script
COPY docker-entrypoint.sh /

# WORKAROUND
# No existence of env LANG causes following error in installing ansible.
#    UnicodeEncodeError: 'ascii' codec can't encode character '\xe9' in position 117: ordinal not in range(128)
ENV LANG=en_US.UTF-8

# Entrypoint and default parameters
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/sbin/init"]
