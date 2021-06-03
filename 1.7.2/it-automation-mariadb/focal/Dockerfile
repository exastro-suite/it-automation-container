##############################################################################
# Stage: Create artifacts

FROM debian:buster as builder

# arguments from command line
ARG EXASTRO_ITA_VER

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

# Copy artifact from builder
WORKDIR /
COPY --from=builder /workspace/artifacts /
