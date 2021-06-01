FROM centos:8

### Required OpenShift Labels
LABEL name="Exastro IT Automation" \
      vendor="NEC Corporation" \
      version="v1.7.2" \
      release="1" \
      summary="Exastro IT Automation container." \
      description="This container provides Exastro IT Automation service."

# Required Licenses
COPY licenses/ /licenses/

# Preprocess script
COPY preprocess.sh /root/

# set command
CMD [ "/sbin/init" ]
