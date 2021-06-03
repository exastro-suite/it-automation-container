DOCKER_BUILDKIT=1 docker build -t foo .

DOCKER_BUILDKIT=1 docker build \
    --tag foo \
    --no-cache \
    --progress=plain \
    --build-arg HTTP_PROXY \
    --build-arg http_proxy \
    --build-arg HTTPS_PROXY \
    --build-arg https_proxy \
    --build-arg NO_PROXY \
    --build-arg no_proxy \
    .
