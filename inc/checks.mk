
.PHONY: inspect
inspect:
	@echo '## $@ ##'
	@echo -n '-    pid: '
	@docker exec $(XQN) xqerl pid
	@echo -n '-    ping: '
	@docker exec $(XQN) xqerl ping
	@echo -n '- current working dir: '
	@$(EVAL) 'file:get_cwd().'
	@echo -n '-   node: '
	@$(EVAL) 'io:format(erlang:node()).' | grep -oP '(.+)(?=ok)'
	@#$(EVAL) 'erlang:nodes().' 
	@echo -n '- cookie: '
	@$(EVAL) 'io:format(erlang:get_cookie()).' | grep -oP '(.+)(?=ok)'
	@echo -n '- hostname: '
	@$(EVAL) 'net:gethostname().'
	@echo -n '-  os get env: '
	@$(EVAL) 'os:getenv().'
	@#$(EVAL) 'os:list_env_vars().'
	@#echo -n '- this cookie: '
	@#$(EVAL) 'erlang:memory().'
	@#$(EVAL) 'code:root_dir().'
	@#echo -n '- loaded: '
	@#$(EVAL) 'erlang:loaded().'
	@#$(EVAL) 'net:ping("xqerl@127.0.0.1").'

.PHONY: info
info:
	@echo -n '- IP address: '
	@docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) 
	@printf %60s | tr ' ' '-' && echo
	@docker ps --filter name=$(XQN) --format ' -    name: {{.Names}}'
	@docker ps --filter name=$(XQN) --format ' -  status: {{.Status}}'
	@echo -n '-    port: '
	@docker ps --format '{{.Ports}}' | grep -oP '^(.+):\K(\d{4})'
	@#docker volume list   --format ' -  volume: {{.Name}}'
	@#docker network list --filter name=$(NETWORK) --format ' - network: {{.Name}}'
	@echo -n '- started: '
	@$(EVAL) 'application:ensure_all_started(xqerl).'
	@printf %60s | tr ' ' '-' && echo
	@docker exec $(XQN) du -h -d 1 .
	@printf %60s | tr ' ' '-' && echo
	@docker exec $(XQN) ldd ./erts-10.5.1/bin/beam.smp
	@printf %60s | tr ' ' '-' && echo
	@docker exec $(XQN) printenv
	@printf %60s | tr ' ' '-' && echo
	@docker exec $(XQN) which xqerl
	@printf %60s | tr ' ' '-' && echo
	@docker exec $(XQN) ls /tmp
	@printf %60s | tr ' ' '-' && echo

.PHONY: check-can-compile-sudoku2
check-can-compile-sudoku2:
	@echo '## $@ ##'
	@echo ' - compile an xQuery file'
	@echo '   should return name of compiled file'
	$(EVAL) 'xqerl:compile("./fixtures/queries/sudoku2.xq")'
	@printf %60s | tr ' ' '-' && echo ''
	@#echo ' - compile, run then grep the title'
	@#xqerl eval 'S = xqerl:compile("./fixtures/queries/sudoku2.xq"),xqerl_node:to_xml(S:main(#{})).'
	@#printf %60s | tr ' ' '-' && echo
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: check-can-compile
check-can-compile:
	@echo '## $@ ##'
	@echo ' - compile an xQuery file'
	@echo '   should return name of compiled file'
	$(EVAL) 'xqerl:compile("./fixtures/queries/example.xq")'
	@printf %60s | tr ' ' '-' && echo 
	@echo ' - compile an xQuery file then run query'
	@echo '   should return query result'
	$(EVAL) 'io:format(xqerl:run(xqerl:compile("./fixtures/queries/example.xq")))'
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: check-can-use-external
check-can-use-external:
	@echo '## $@ ##'
	@echo ' - compile an xQuery file then run query'
	@echo '   passing an external arg "hey hey" to the compiled xQuery'
	@$(EVAL) 'J = xqerl:compile("./fixtures/queries/example2.xq"),C = #{<<"msg">> => <<"hey hey">>},io:format(J:main(C)).' \
 | grep -oP '(.+)(?=ok)'
	@printf %60s | tr ' ' '-' && echo ''

.phony: db-can-insert
db-can-insert:
	@echo '## $@ ##'
	@echo -n ' - check insert doc into db: '
	@$(EVAL) \
 'xqldb_dml:insert_doc("http://xqerl.org/archive/my_doc.xml","./fixtures/data/xml/functx_order.xml").' 
	@printf %60s | tr ' ' '-' && echo ''

.phony: db-can-get
db-can-get:
	@echo '## $@ ##'
	@echo -n ' - retrieve stored document from database: '
	@$(EVAL) \
 'io:format(xqerl_node:to_xml(xqerl:run("doc(\"http://xqerl.org/archive/my_doc.xml\")"))).' \
 | grep -oP 'ok$$'
	@$(EVAL) \
 'io:format(xqerl_node:to_xml(xqerl:run("doc(\"http://xqerl.org/archive/my_doc.xml\")"))).' 
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: db-can-delete
db-can-delete:
	@echo '## $@ ##'
	@echo ' -  delete stored document from database'
	$(EVAL) 'xqldb_dml:delete_doc("http://xqerl.org/my_doc.xml").'
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' -  try to fetch from database, the deleted document'
	@echo '    should throw an error'
	$(EVAL) 'xqerl:run("doc(\"http://xqerl.org/my_doc.xml\")").'
	@printf %60s | tr ' ' '=' && echo ''

.phony: db-can-list-stored-items-in-collection
db-can-list-stored-items-in-collection:
	@echo '## $@ ##'
	@echo ' - use `fn:uri-collection()` to list items'
	@$(EVAL) \
 'xqerl:run("fn:uri-collection(\"http://xqerl.org/archive\")").' | \
 grep -oP '\{xqAtomicValue.+$$'
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: routes 
routes:
	@echo '## $@ ##'
	@echo ' -  compile restXQ functions to run on the beam'
	@$(EVAL) 'xqerl:compile("./fixtures/queries/tests-restXQ.xqm")'
	@printf %60s | tr ' ' '-' && echo ''


ADDRESS = http://localhost:8081

.PHONY: route-get-xml
route-get-xml:
	@echo '## $@ ##'
	@curl -s $(ADDRESS)/test/get/xml | \
 grep -oP '<root>(.+)</root>'
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: route-get-csv
route-get-csv:
	@printf %60s | tr ' ' '=' && echo
	@echo '## $@ ##'
	@curl -s $(ADDRESS)/test/get/csv 
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: route-get-html
route-get-html:
	@printf %60s | tr ' ' '=' && echo
	@echo '## $@ ##'
	@curl -s $(ADDRESS)/test/get/html 
	@echo;printf %60s | tr ' ' '-' && echo ''

.PHONY: route-get-json
route-get-json:
	@printf %60s | tr ' ' '=' && echo
	@echo '## $@ ##'
	@curl -s $(ADDRESS)/test/get/json | jq -M '.'
	@echo;printf %60s | tr ' ' '-' && echo ''

.PHONY: route-head
route-head:
	@printf %60s | tr ' ' '=' && echo
	@echo '## $@ ##'
	@curl -v --head "$(ADDRESS)/test/head/xml"
	@echo;printf %60s | tr ' ' '-' && echo ''

.PHONY: route-head-redirect
route-head-redirect:
	@echo '## $@ ##'
	@curl -v --head "$(ADDRESS)/test/head/redirect" |\
 grep  'location'
	@printf %60s | tr ' ' '-' && echo ''


.PHONY: route-options
route-options:
	@echo '## $@ ##'
	@curl -v -X OPTIONS "$(ADDRESS)/test/options/xml"
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: route-post-form
route-post-form:
	@echo '## $@ ##'
	@curl -v \
 --data-urlencode "message=Insomniac Rust" \
 --data-urlencode "message2=Never Sleeps" \
 "$(ADDRESS)/test/post/form"
	@echo;printf %60s | tr ' ' '-' && echo ''

define t_md
# hi de hi

happy campers of the world unite
endef

route-form-multi: export t_md:=$(t_md)
route-form-multi:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@echo "$${t_md}"
	@echo "$${t_md}" > ./test.md
	@printf %60s | tr ' ' '-' && echo ''
	@curl -v \
  --form files=@./test.md \
  $(ADDRESS)/test/post/form_multi
	@rm ./test.md
	@echo;printf %60s | tr ' ' '-' && echo ''

define t_xml
<root>
  <a>text</a>
</root>
endef

route-post-xml-file: export t_xml:=$(t_xml)
route-post-xml-file:
	@echo '## $@ ##'
	@echo "$${t_xml}" | curl -s \
 -H 'Content-Type: application/xml' \
  --data-binary @- $(ADDRESS)/test/post/xml
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: route-post-xml-string
route-post-xml-string:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -s \
 -H "Content-Type: application/xml" \
 -d '<root>branch</root>' \
 "$(ADDRESS)/test/post/xml"
	@@echo;printf %60s | tr ' ' '-' && echo ''

route-create: export t_xml:=$(t_xml)
route-create:
	@echo '## $@ ##'
	@echo "$${t_xml}" | curl -v \
 -H 'Content-Type: application/xml' \
  --data-binary @- \
  $(ADDRESS)/test/post/get?id=toast
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: route-get-created-resource
route-get-created-resource:
	@echo '## $@ ##'
	@curl -s \
  $(ADDRESS)/test/post/get/doc/toast
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: route-delete-resource
route-delete-resource:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -v -X DELETE \
  $(ADDRESS)/test/post/get/doc/toast
	@printf %60s | tr ' ' '-' && echo ''
