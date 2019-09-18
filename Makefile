include .env
XQN=$(XQERL_CONTAINER_NAME)
EVAL=docker exec $(XQN) ./bin/xqerl eval

define mkHelp
-------------------------------------------------------------------------------
targets:
 - to build docker image
make build 
 - to build image only to shell target
make build TARGET=shell





 


-------------------------------------------------------------------------------
endef


help: export HELP=$(mkHelp)
help:
	@echo "$${HELP}"

.PHONY: run-shell
run-shell:
	@docker run \
  -it --rm \
  --name xq1 \
  --network www \
  --publish 8081:8081 \
  --log-driver=$(XQERL_LOG_DRIVER) \
  grantmacken/alpine-xqerl:shell

.PHONY: inspect
inspect:
	@curl -v \
 http://$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) ):8081


.PHONY: check-error-lines
check-error-lines:
	@echo ' - copy xQuery file into container '
	@docker exec $(XQN) rm -v -rf /tmp/fixtures 
	@docker cp fixtures $(XQN):/tmp/fixtures
	@#docker exec $(XQN) ls /tmp
	@echo ' - compile and run an xQuery file'
	$(EVAL) 'xqerl:run(xqerl:compile("/tmp/fixtures/example.xq"))'
	@echo ' - try to compile xQuery with a static error  '
	@echo '   should be able to grep *type* error code XPST0081'
	$(EVAL) 'xqerl:compile("/tmp/fixtures/XPST0081.xq")' | grep -oP 'XPST0081'
	@echo '   should be able to grep error message'
	$(EVAL) 'xqerl:compile("/tmp/fixtures/XPST0081.xq")' | grep -oP '.+\K"It is a static(.+)">>'
	@echo '  TODO should be able to grep error "file path"'
	@echo '  TODO should be able to grep error "line number"'

xxx:
	@echo '   should return  *type* error XPTY0004'
	@$(EVAL) 'xqerl:compile("/tmp/fixtures/XPTY0004.xq")' | grep -oP 'XPTY0004'
	@echo '   should return  *static* error' 'XQST0076'
	@$(EVAL) 'xqerl:compile("/tmp/fixtures/XQST0076.xq")' | grep -oP 'XQST0076'
	@echo '   should return  *static* error' 'XQST0076 with associated error line number'
	@$(EVAL) 'xqerl:compile("/tmp/fixtures/XQST0076.xq")' | grep -oP 'XQST0076'


.PHONY: check
check:
	@# docker ps -a
	@#docker-compose logs
	@echo -n '- IP address: '
	@docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) 
	@printf %60s | tr ' ' '-' && echo
	@docker ps --filter name=$(XQN) --format ' -    name: {{.Names}}'
	@docker ps --filter name=$(XQN) --format ' -  status: {{.Status}}'
	@echo -n '-    port: '
	@docker ps --format '{{.Ports}}' | grep -oP '^(.+):\K(\d{4})'
	@#docker volume list 
	@docker volume list   --format ' -  volume: {{.Name}}'
	@docker network list --filter name=$(NETWORK) --format ' - network: {{.Name}}'
	@echo -n '- started: '
	@$(EVAL) 'application:ensure_all_started(xqerl).'
	@printf %60s | tr ' ' '=' && echo 
	@echo ' - run a query '
	$(EVAL) 'xqerl:run("xs:token(\"cats\"), xs:string(\"dogs\"), true() ").'
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' - copy xQuery file into container '
	docker cp fixtures/sudoku2.xq $(XQN):/tmp
	@echo ' - list files in tmp'
	@docker exec $(XQN) ls /tmp
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' - compile an xQuery file'
	@echo '   should return name of compiled file'
	$(EVAL) 'xqerl:compile("/tmp/sudoku2.xq")'
	@printf %60s | tr ' ' '-' && echo 
	@echo ' - compile an xQuery file then run query'
	@echo '   should return query result as XML'
	$(EVAL) 'S = xqerl:compile("/tmp/sudoku2.xq"),xqerl_node:to_xml(S:main(#{})).'
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' - copy XML file into container '
	@docker -v cp fixtures/functx_order.xml $(XQN):/tmp
	@docker exec $(XQN) ls /tmp
	@echo ' - insert XML document into database'
	$(EVAL) 'xqldb_dml:insert_doc("http://xqerl.org/my_doc.xml","/tmp/functx_order.xml").'
	@#docker exec $(XQERL_CONTAINER_NAME) cat ./log/erl.log
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' - run xQuery expression doc() to fetch document from db '
	$(EVAL) "xqerl_node:to_xml(xqerl:run(\"doc('http://xqerl.org/my_doc.xml')\"))."
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' -  delete document in database'
	$(EVAL) 'xqldb_dml:delete_doc("http://xqerl.org/my_doc.xml").'
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' -  try to fetch from database, the deleted document'
	@echo '    should throw an error'
	$(EVAL) "xqerl_node:to_xml(xqerl:run(\"doc('http://xqerl.org/my_doc.xml')\"))."
	@printf %60s | tr ' ' '=' && echo ''

.PHONY: example
example:
	@docker -v cp fixtures/rest.xq $(XQN):/tmp
	@$(EVAL) 'xqerl:compile("/tmp/rest.xq")'

.PHONY: up
up:
	@docker-compose up -d

.PHONY: down
down:
	@docker-compose down

.PHONY: build
build:
	@docker build \
  --target="$(if $(TARGET),$(TARGET),min)" \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),v$(DOCKER_TAG))" \
 .

.PHONY: branch-build
branch-build:
	@docker build \
  --target="$(if $(TARGET),$(TARGET),min)" \
  --build-arg BRANCH=$(XQERL_REPO_BRANCH) \
  --tag="$(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),v$(DOCKER_TAG))" \
 .

.PHONY: push
push:
	@echo '## $@ ##'
	@docker push $(DOCKER_IMAGE):$(if $(TARGET),$(TARGET),v$(DOCKER_TAG))

.PHONY: clean
clean:
	@docker image prune -a
	@docker container prune
	@docker rmi $$(docker images -a | grep "xqerl" | awk '{print $$3}')

.PHONY: travis
travis: 
	@travis env set DOCKER_USERNAME $(shell git config --get user.name)
	@#travis env set DOCKER_PASSWORD
	@travis env list

.PHONY: network 
network: 
	@docker network create $(NETWORK)

.PHONY: rec
rec:
	@mkdir -p ../tmp
	@asciinema rec ../tmp/csv.cast \
 --overwrite \
 --title='grantmacken/alpine-xqerl ran `make up'\
 --idle-time-limit 1 \
 --command="\
sleep 1 && printf %60s | tr ' ' '='  && echo && \
echo ' - start the container ... ' && \
make --silent up   && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - check running container status ... ' && \
make --silent check   && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - example xqerl command using \"docker exec\" ... ' && \
echo 'xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \"). ... '  && \
make --silent do   && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
make --silent down && \
sleep 1 && printf %60s | tr ' ' '='  && echo\
"

PHONY: play
play:
	@clear && asciinema play ../tmp/csv.cast

.PHONY: upload
upload:
	asciinema upload ../tmp/csv.cast
