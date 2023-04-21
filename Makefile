export PROJECT = temporal

k8s: k8s/temporal.yaml k8s/temporal-postgres.yaml k8s/temporal-mysql.yaml k8s/temporal-mysql-es.yaml k8s/temporal-cass.yaml k8s/temporal-cass-es.yaml

k8s/temporal.yaml: docker-compose.yml
	kompose convert -f $< -o $@
	yq -i '(.items.[] | select(.kind == "Deployment") | .spec.template.spec.enableServiceLinks) = false' $@

k8s/temporal-%.yaml: docker-compose-%.yml
	kompose convert -f $< -o $@
	yq -i '(.items.[] | select(.kind == "Deployment") | .spec.template.spec.enableServiceLinks) = false' $@

create-network:
	-docker network create temporal_network

up:	create-network ## start the services in background
	docker-compose -p $(PROJECT) up -d $(c)
	
logs:	## displays logs
	docker-compose -p $(PROJECT) logs --tail=100 -f $(c)

login-admin:	## log into service container's shell
	docker-compose -p $(PROJECT) exec temporal-admin-tools bash