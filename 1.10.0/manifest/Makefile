##############################################################################
# Targets

.PHONY: clean
clean:
	-kubectl delete -f it-automation.yml
	-kubectl delete -f init-volume.yml


.PHONY: init
init:
	kubectl apply -f init-volume.yml


.PHONY: deploy
deploy:
	kubectl apply -f it-automation.yml
	kubectl apply -f ingress.yml


.PHONY: undeploy
undeploy:
	kubectl delete -f it-automation.yml
