##############################################################################
# Targets

CHART_VERSION ?= 1.10.0
CHART_RELEASE_NAME ?= ita-prod
CHART_NAMESPACE ?= default


##############################################################################
# Targets

.PHONY: clean
clean:
	-minikube delete
	-rm -f *.tgz


.PHONY: start
start:
	minikube start \
		--extra-config=kubelet.image-pull-progress-deadline=5m \
		--embed-certs \
		--driver=kvm2 \
		--memory=8g


.PHONY: stop
stop:
	minikube stop


.PHONY: service
service:
	minikube service $(CHART_RELEASE_NAME)-it-automation-webapp --url


.PHONY: package
package:
	helm package it-automation


.PHONY: install
install:
	helm install \
		--namespace $(CHART_NAMESPACE) \
		--create-namespace \
		--timeout 15m \
		$(CHART_RELEASE_NAME) \
		it-automation-$(CHART_VERSION).tgz


.PHONY: install-no-hook
install-no-hook:
	helm install \
		--namespace $(CHART_NAMESPACE) \
		--create-namespace \
		--timeout 15m \
		--no-hooks \
		$(CHART_RELEASE_NAME) \
		it-automation-$(CHART_VERSION).tgz


.PHONY: dry-run
dry-run:
	helm install \
		--debug \
		--dry-run \
		$(CHART_RELEASE_NAME) \
		it-automation-$(CHART_VERSION).tgz


.PHONY: uninstall
uninstall:
	helm uninstall $(CHART_RELEASE_NAME)
