##############################################################################
# Arguments from command line

#ARG EXASTRO_ITA_VER
#ARG EXASTRO_ITA_LANG
#ARG EXASTRO_ITA_DB_NAME
#ARG EXASTRO_ITA_DB_USERNAME
#ARG EXASTRO_ITA_DB_PASSWORD


##############################################################################
# Stage: Create artifacts

FROM debian:buster as builder

ARG EXASTRO_ITA_VER
ARG EXASTRO_ITA_LANG
ARG EXASTRO_ITA_INSTALL_DIR
ARG EXASTRO_ITA_DB_NAME
ARG EXASTRO_ITA_DB_USERNAME
ARG EXASTRO_ITA_DB_PASSWORD

# update root ca if any
RUN --mount=type=secret,id=extra-root-ca \
if [ -f /run/secrets/extra-root-ca ]; then \
    cp /run/secrets/extra-root-ca /usr/local/share/ca-certificates/extra-root-ca.crt; \
    update-ca-certificates; \
fi

# create workspace for build and change working directory
RUN mkdir /workspace
WORKDIR /workspace

# build
COPY create-artifacts.sh create-artifacts.sh
RUN ./create-artifacts.sh


##############################################################################
# Stage: Create the image

FROM mariadb:10.5-focal

ENV EXASTRO_ITA_VER=${EXASTRO_ITA_VER}
ENV EXASTRO_ITA_LANG=${EXASTRO_ITA_LANG}

# Copy artifact from builder
COPY --from=builder /workspace/artifacts /
