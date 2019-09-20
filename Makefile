include .env
XQN=$(XQERL_CONTAINER_NAME)
EVAL=docker exec $(XQN) ./bin/xqerl eval


Address = http://$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) ):8081

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
	@docker inspect -f '{{.HostConfig.LogConfig.Type}}' $(XQN)
	@printf %60s | tr ' ' '-' && echo
	@curl -v \
 http://$(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) ):8081

.PHONY: info
info:
	@echo -n '- IP address: '
	@docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) 
	@printf %60s | tr ' ' '-' && echo
	@docker ps --filter name=$(XQN) --format ' -    name: {{.Names}}'
	@docker ps --filter name=$(XQN) --format ' -  status: {{.Status}}'
	@echo -n '-    port: '
	@docker ps --format '{{.Ports}}' | grep -oP '^(.+):\K(\d{4})'
	@docker volume list   --format ' -  volume: {{.Name}}'
	@docker network list --filter name=$(NETWORK) --format ' - network: {{.Name}}'
	@echo -n '- started: '
	@$(EVAL) 'application:ensure_all_started(xqerl).'

check-can-run-expression:
	@printf %60s | tr ' ' '=' && echo 
	@echo '## $@ ##'
	@echo ' - run a xQuery expression'
	@$(EVAL) \
 'xqerl:run("xs:token(\"cats\"), xs:string(\"dogs\"), true() ").' | grep -oP '^\[\{xq.+$$'

check-copy-into-container:
	@printf %60s | tr ' ' '=' && echo 
	@echo '## $@ ##'
	@#docker exec $(XQN) rm -fr /tmp/
	@docker cp fixtures $(XQN):/tmp
	docker exec $(XQN) ls /tmp/fixtures
	@#docker exec $(XQN) rm -rf /tmp/fixtures

check-can-compile:
	@printf %60s | tr ' ' '-' && echo 
	@echo '## $@ ##'
	@echo ' - compile an xQuery file'
	@echo '   should return name of compiled file'
	$(EVAL) 'xqerl:compile("/tmp/fixtures/example.xq")'
	@printf %60s | tr ' ' '-' && echo 
	@echo ' - compile an xQuery file then run query'
	@echo '   should return query result'
	$(EVAL) 'io:format(xqerl:run(xqerl:compile("/tmp/fixtures/example.xq")))'

check-can-use-external:
	@printf %60s | tr ' ' '=' && echo 
	@echo '## $@ ##'
	@docker cp fixtures $(XQN):/tmp
	@printf %60s | tr ' ' '-' && echo 
	@echo ' - compile an xQuery file then run query'
	@echo '   passing an external arg "hey hey" to the compiled xQuery'
	$(EVAL) 'J = xqerl:compile("/tmp/fixtures/example2.xq"),C = #{<<"msg">> => <<"hey hey">>},io:format(J:main(C)).'
	@printf %60s | tr ' ' '-' && echo ''

check-can-use-node-to-xml:
	@printf %60s | tr ' ' '=' && echo 
	@echo '## $@ ##'
	@echo ' - compile an xQuery file then run query'
	@echo '   should output xml, should be able to then grep title'
	@$(EVAL) 'S = xqerl:compile("/tmp/fixtures/sudoku2.xq"),io:format(xqerl_node:to_xml(S:main(#{}))).' | \
 grep -oP '<title>(.+)</title>'

check-can-load-data-into-db:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@echo ' - insert XML document into database'
	$(EVAL) 'xqldb_dml:insert_doc("http://xqerl.org/my_doc.xml","/tmp/fixtures/functx_order.xml").' || true
	@printf %60s | tr ' ' '-' && echo ''

check-can-load-data-from-db:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@echo ' - run xQuery expression doc() to fetch document from db '
	$(EVAL) "xqerl_node:to_xml(xqerl:run(\"doc('http://xqerl.org/my_doc.xml')\"))."
	@printf %60s | tr ' ' '-' && echo ''

todoxxx:
	@printf %60s | tr ' ' '-' && echo ''
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

check-can-set-restXQ-routes:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@docker cp fixtures $(XQN):/tmp
	@echo ' -  compile restXQ function to run on the beam'
	@$(EVAL) 'xqerl:compile("/tmp/fixtures/rest.xq")'
	@echo ' -  use restXQ defined endpoint to insert data in db'
	@curl -v $(Address)/insert

check-can-GET-restXQ-route:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -s $(Address) | grep -oP '<th>(.+)</th>'
	@printf %60s | tr ' ' '-' && echo ''
	@curl -s $(Address)/route/detail?id=a | grep -oP '<th>(.+)</th>'

xxxx:
	grep -oP '<title>(.+)</title>'
	@printf %60s | tr ' ' '-' && echo ''
	@curl -v $(Address)/route/detail?id=a
	@printf %60s | tr ' ' '-' && echo ''
	@printf %60s | tr ' ' '-' && echo ''

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
