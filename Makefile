include .env
include inc/checks.mk
include inc/run.mk

#XQN=shell
XQN=$(XQERL_CONTAINER_NAME)
EVAL=docker exec $(XQN) xqerl eval

Address = http://$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) ):8081

define mkHelp
-------------------------------------------------------------------------------
targets:
 - to build docker image
make build 
 - to build image only to shell target
make build TARGET=shell

-------------------------------------------------------------------------------
Note:
tag now from zadean git heads/master ref sha

endef



HEAD_SHA != curl -s https://api.github.com/repos/zadean/xqerl/git/ref/heads/master | jq -Mr '.object.sha'
THIS_SHA != grep -oP 'REPO_SHA=\K(.+)' .env

.PHONY: build
build: sha
	@export DOCKER_BUILDKIT=1;
	LATEST=$(THIS_SHA);\
  docker buildx build -o type=docker \
  --target="$(if $(TARGET),$(TARGET),min)" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),$(THIS_SHA))" \
  --tag="$(DOCKER_IMAGE):latest" \
 .
	@echo

.PHONY: sha
sha:
	@echo "previous commit sha: $(THIS_SHA)"
	@LATEST=$(HEAD_SHA);echo "  latest commit sha: $$LATEST";\
  if [ ! "$$LATEST" = "$(THIS_SHA)" ]; then sed -i 's/REPO_SHA.*/REPO_SHA=$(HEAD_SHA)/' .env ; fi

.PHONY: up
up:
	@docker-compose up -d

.PHONY: down
down:
	@docker-compose down

.PHONY: clean
clean:
	@#docker image prune -a
	@#docker container prune
	@docker rmi $$(docker images -a | grep "xqerl" | awk '{print $$3}')

.PHONY: network 
network: 
	@docker network create $(NETWORK)

help: export HELP=$(mkHelp)
help:
	@echo "$${HELP}"
