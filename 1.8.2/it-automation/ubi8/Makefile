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

# Preprocess
EXASTRO_ITA_INSTALLER_URL ?= https://github.com/exastro-suite/it-automation/releases/download/v$(EXASTRO_ITA_VER)/exastro-it-automation-$(EXASTRO_ITA_VER).tar.gz
EXASTRO_ITA_UNPACK_BASE_DIR ?= /root
EXASTRO_ITA_UNPACK_DIR_NAME ?= it-automation-$(EXASTRO_ITA_VER)
EXASTRO_ITA_UNPACK_DIR := $(EXASTRO_ITA_UNPACK_BASE_DIR)/$(EXASTRO_ITA_UNPACK_DIR_NAME)

# Execution
FILE_VOLUME_HOST_PATH := $(CURDIR)/tmp/exastro-file-volume
DATABASE_VOLUME_HOST_PATH := $(CURDIR)/tmp/exastro-database-volume

ifdef USE_FILE_VOLUME
FILE_VOLUME_OPTION := --volume $(FILE_VOLUME_HOST_PATH):/exastro-file-volume
endif

ifdef INIT_FILE_VOLUME
FILE_VOLUME_OPTION := $(FILE_VOLUME_OPTION) --env EXASTRO_AUTO_FILE_VOLUME_INIT=true
endif

ifdef USE_DATABASE_VOLUME
DATABASE_VOLUME_OPTION := --volume $(DATABASE_VOLUME_HOST_PATH):/exastro-database-volume
endif

ifdef INIT_DATABASE_VOLUME
DATABASE_VOLUME_OPTION := $(DATABASE_VOLUME_OPTION) --env EXASTRO_AUTO_DATABASE_VOLUME_INIT=true
endif


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
		$(DOCKER_BUILD_OPT_SECRET) \
		./

	docker run \
		--detach \
		--privileged \
		--env EXASTRO_ITA_VER=$(EXASTRO_ITA_VER) \
		--env EXASTRO_ITA_LANG=$(EXASTRO_ITA_LANG) \
		--name $(BUILDER_CONTAINER_NAME) \
		$(IMAGE_FULL_NAME)

	sleep 10

	docker exec \
		--tty \
		--env HTTP_PROXY \
		--env http_proxy \
		--env HTTPS_PROXY \
		--env https_proxy \
		--env NO_PROXY \
		--env no_proxy \
		--env EXASTRO_ITA_INSTALLER_URL=$(EXASTRO_ITA_INSTALLER_URL) \
		--env EXASTRO_ITA_UNPACK_BASE_DIR=$(EXASTRO_ITA_UNPACK_BASE_DIR) \
		--env EXASTRO_ITA_UNPACK_DIR=$(EXASTRO_ITA_UNPACK_DIR) \
		$(BUILDER_CONTAINER_NAME) \
		/root/preprocess.sh

	docker exec \
		--tty \
		--env HTTP_PROXY \
		--env http_proxy \
		--env HTTPS_PROXY \
		--env https_proxy \
		--env NO_PROXY \
		--env no_proxy \
		--workdir=$(EXASTRO_ITA_UNPACK_DIR)/ita_install_package/install_scripts \
		$(BUILDER_CONTAINER_NAME) \
		/bin/sh -x ita_installer.sh

	docker exec \
		--tty \
		--env HTTP_PROXY \
		--env http_proxy \
		--env HTTPS_PROXY \
		--env https_proxy \
		--env NO_PROXY \
		--env no_proxy \
		$(BUILDER_CONTAINER_NAME) \
		/root/postprocess.sh

	docker stop \
		$(BUILDER_CONTAINER_NAME)

	docker commit \
		$(BUILDER_CONTAINER_NAME) \
		$(IMAGE_FULL_NAME)


.PHONY: push
push:
	docker push $(IMAGE_FULL_NAME)


.PHONY: evidence
evidence:
	mkdir tmp

	mkdir tmp/install-log
	-docker cp \
		$(BUILDER_CONTAINER_NAME):$(EXASTRO_ITA_UNPACK_DIR)/ita_install_package/install_scripts/log/. \
		tmp/install-log/

	-docker inspect \
		$(BUILDER_CONTAINER_NAME) \
		> tmp/inspect.txt


.PHONY: run
run: delete
	docker run \
		--name $(IMAGE_NAME) \
		--privileged \
		--add-host=exastro-it-automation:127.0.0.1 \
		-d \
		-p 8080:80 \
		-p 10443:443 \
		$(FILE_VOLUME_OPTION) \
		$(DATABASE_VOLUME_OPTION) \
		$(IMAGE_FULL_NAME)


.PHONY: stop
stop:
	-docker stop $(IMAGE_NAME)


.PHONY: delete
delete: stop
	-docker rm $(IMAGE_NAME)
