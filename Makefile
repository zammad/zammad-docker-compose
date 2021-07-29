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

start-stg:
	@echo
	@echo "+++ build / run Helpdesk +++"
	sudo sysctl -w vm.max_map_count=262144
	docker-compose -f docker-compose.yml -f docker-compose.stg.yml up -d

shutdown-stg:
	@echo
	@echo "+++ shutdown Helpdesk +++"
	docker-compose -f docker-compose.yml -f docker-compose.stg.yml down

build-stg:
	@echo
	@echo "+++ shutdown Helpdesk +++"
	docker-compose -f docker-compose.yml -f docker-compose.stg.yml build