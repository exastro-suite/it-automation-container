##############################################################################
# Constants

# Exastro IT Automation
EXASTRO_ITA_VER := $(shell basename $(shell dirname $(shell dirname $(CURDIR))))
EXASTRO_ITA_LANG ?= ja
EXASTRO_ITA_INSTALL_DIR ?= /exastro

# Database
EXASTRO_ITA_DB_HOST ?= localhost
EXASTRO_ITA_DB_PORT ?= 3306
EXASTRO_ITA_DB_NAME ?= ita_db
EXASTRO_ITA_DB_USERNAME ?= ita_db_user
EXASTRO_ITA_DB_PASSWORD ?= ita_db_password
EXASTRO_ITA_DB_ROOT_PASSWORD ?= ita_root_password
EXASTRO_ITA_DB_SERVICE_NAME ?= it-automation-mariadb

# Distro
DISTRO_SYMBOL := $(shell basename $(CURDIR))

# Image
IMAGE_NAME := $(shell basename $(shell dirname $(CURDIR)))

ifdef USE_GITHUB_PACKAGES
IMAGE_HOST_AND_PATH := $(shell git config remote.origin.url | sed -E "s@^https://github.com/([^/]+)/.*@ghcr.io/\1/@")
else
IMAGE_HOST_AND_PATH ?= 
endif

IMAGE_FULL_NAME := $(IMAGE_HOST_AND_PATH)$(IMAGE_NAME):$(EXASTRO_ITA_VER)-$(EXASTRO_ITA_LANG)-$(DISTRO_SYMBOL)

# Builder container
BUILDER_CONTAINER_NAME := $(IMAGE_NAME)-$(EXASTRO_ITA_VER)-$(EXASTRO_ITA_LANG)-$(DISTRO_SYMBOL)-builder

# Extra root CA
ifneq ($(origin EXASTRO_EXTRA_ROOT_CA), undefined)
DOCKER_BUILD_OPT_SECRET := --secret id=extra-root-ca,src=$(EXASTRO_EXTRA_ROOT_CA)
endif

# Volume archive
EXASTRO_ITA_VOLUME_ARCHIVE := $(IMAGE_HOST_AND_PATH)it-automation:$(EXASTRO_ITA_VER)-$(EXASTRO_ITA_LANG)-$(DISTRO_SYMBOL)


##############################################################################
# Targets

.PHONY: clean
clean:
	-docker stop $(BUILDER_CONTAINER_NAME)
	-docker rm $(BUILDER_CONTAINER_NAME)


.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build \
		--tag $(IMAGE_FULL_NAME) \
		--no-cache \
		--build-arg EXASTRO_ITA_VER=$(EXASTRO_ITA_VER) \
		--build-arg EXASTRO_ITA_VOLUME_ARCHIVE=$(EXASTRO_ITA_VOLUME_ARCHIVE) \
		$(DOCKER_BUILD_OPT_SECRET) \
		./


.PHONY: push
push:
	docker push $(IMAGE_FULL_NAME)


.PHONY: evidence
evidence:
	mkdir tmp

	-docker inspect \
		$(BUILDER_CONTAINER_NAME) \
		> tmp/inspect.txt
