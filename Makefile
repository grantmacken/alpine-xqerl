include .env

default: 
	@echo 'WIP'

.PHONY: check
check:
	@docker exec $(XQERL_CONTAINER_NAME) ls -al ./bin
	@docker exec $(XQERL_CONTAINER_NAME) ./bin/xqerl eval 'application:ensure_all_started(xqerl).'
	@docker exec $(XQERL_CONTAINER_NAME) ./bin/xqerl eval "xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \")."

.PHONY: up
up:
	@docker-compose up -d

.PHONY: down
down:
	@docker-compose down


.PHONY: build
build:
	@docker build \
  --tag="$(DOCKER_IMAGE):$(DOCKER_TAG)" \
  --tag="$(DOCKER_IMAGE):v$(shell date --iso | sed s/-//g)" \
 .


.PHONY: push
push:
	@echo '## $@ ##'
	@docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	@docker push $(DOCKER_IMAGE):v$(shell date --iso | sed s/-//g)

.PHONY: clean
clean:
	@docker images -a | grep "grantmacken" | awk '{print $3}' | xargs docker rmi

.PHONY: travis
travis: 
	@travis env set DOCKER_USERNAME $(shell git config --get user.name)
	@#travis env set DOCKER_PASSWORD
	@travis env list
