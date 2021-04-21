FROM registry.access.redhat.com/ubi8/ubi-init

### Required OpenShift Labels
LABEL name="Exastro IT Automation" \
      vendor="NEC Corporation" \
      version="v1.6.3" \
      release="1" \
      summary="Exastro IT Automation container." \
      description="This container provides Exastro IT Automation service."

# systemd must be executed by root
USER root

# Required Licenses
COPY licenses/ /licenses/

# Preprocess script
COPY preprocess.sh /root/
