FROM registry.access.redhat.com/ubi8/ubi

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
COPY exastro-initial-volume-archive/ /exastro-initial-volume-archive/

# Entrypoint script
COPY docker-entrypoint.sh /

# Entrypoint and default parameters
ENTRYPOINT ["/docker-entrypoint.sh"]
