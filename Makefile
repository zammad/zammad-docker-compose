###############################################################################
## Makefile - zammad-docker-compose                                          ##
###############################################################################

start-prod:
	@echo
	@echo "+++ build / run Helpdesk +++"
	sudo sysctl -w vm.max_map_count=262144
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

shutdown-prod:
	@echo
	@echo "+++ shutdown Helpdesk +++"
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml down

build-prod:
	@echo
	@echo "+++ shutdown Helpdesk +++"
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml build