##############################################################################
# Constants

# Exastro IT Automation
IMAGE_VER := 1.0.0

# Image
IMAGE_NAME := $(shell basename $(CURDIR))

ifdef USE_GITHUB_PACKAGES
IMAGE_HOST_AND_PATH := $(shell git config remote.origin.url | sed -E "s@^https://github.com/([^/]+)/.*@ghcr.io/\1/@")
else
IMAGE_HOST_AND_PATH ?= 
endif

IMAGE_FULL_NAME := $(IMAGE_HOST_AND_PATH)$(IMAGE_NAME):$(IMAGE_VER)

# Extra root CA
ifneq ($(origin EXASTRO_EXTRA_ROOT_CA), undefined)
DOCKER_BUILD_OPT_SECRET := --secret id=extra-root-ca,src=$(EXASTRO_EXTRA_ROOT_CA)
endif


##############################################################################
# Targets

.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build \
		--tag $(IMAGE_FULL_NAME) \
		--no-cache \
		$(DOCKER_BUILD_OPT_SECRET) \
		./


.PHONY: clean
clean:
	echo "nothing to do"


.PHONY: push
push:
	docker push $(IMAGE_FULL_NAME)
