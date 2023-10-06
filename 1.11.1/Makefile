##############################################################################
# Constants

# Distro
DISTRO_SYMBOL ?= ubi8


##############################################################################
# Targets

.PHONY: clean
clean:
	echo "do nothing."


.PHONY: build
build:
	for IMAGE_NAME in $$(cat image-names-single-type.txt image-names-multi-type.txt); do \
	    $(MAKE) -C $${IMAGE_NAME}/$(DISTRO_SYMBOL) build; \
	done

