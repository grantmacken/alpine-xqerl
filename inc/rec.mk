
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
	$(EVAL) 'xqerl:compile("/tmp/example.xq")'
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
	$(EVAL) 'J = xqerl:compile("/tmp/example2.xq"),C = #{<<"msg">> => <<"hey hey">>},io:format(J:main(C)).'
	@printf %60s | tr ' ' '-' && echo ''

check-can-use-node-to-xml:
	@printf %60s | tr ' ' '=' && echo 
	@echo '## $@ ##'
	@echo ' - compile an xQuery file then run query'
	@echo '   should output xml, should be able to then grep title'
	@$(EVAL) 'S = xqerl:compile("/tmp/sudoku2.xq"),io:format(xqerl_node:to_xml(S:main(#{}))).' | \
 grep -oP '<title>(.+)</title>'

# fn:parse-xml-fragment($arg as xs:string?) 
#'xqldb_dml:insert_doc("http://xqerl.org/my_doc.xml","/tmp/fixtures/functx_order.xml").' || true
.PHONY: db-can-insert
db-can-insert:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@echo ' - insert XML document into database'
	@$(EVAL) 'xqldb_dml:insert_doc("http://xqerl.org/my_doc.xml","/tmp/small.xml").'


.PHONY: db-can-load-data
db-can-load-data:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@echo ' - run xQuery expression doc() to fetch document from db '
	$(EVAL) "io:format(xqerl_node:to_xml(xqerl:run(\"doc('http://xqerl.org/my_doc.xml')\")))."
	@printf %60s | tr ' ' '-' && echo ''

.PHONY: db-can-delete
db-can-delete:
	@echo ' -  delete document in database'
	$(EVAL) 'xqldb_dml:delete_doc("http://xqerl.org/my_doc.xml").'
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' -  try to fetch from database, the deleted document'
	@echo '    should throw an error'
	$(EVAL) "xqerl_node:to_xml(xqerl:run(\"doc('http://xqerl.org/my_doc.xml')\"))."
	@printf %60s | tr ' ' '=' && echo ''



.PHONY: routes
routes:
	@echo '## $@ ##'
	@echo ' -  compile restXQ function to run on the beam'
	@$(EVAL) 'xqerl:compile("/tmp/routes.xqm")'

.PHONY: route-get-landing
route-get-landing:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@#curl -v $(Address)/markup.nz/landing
	@echo '## $@ ##'
	@w3m -dump $(Address)/markup.nz/landing

.PHONY: route-get-params
route-get-params:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -v "$(Address)/params?h=entry&content=test" | jq '.'

.PHONY: route-get-params2
route-get-params2:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -v -G \
 --data "h=entry" \
 --data-urlencode "content=Rust Never Sleeps" \
 "$(Address)/params" | jq '.'




.PHONY: route-form-multipart
route-form-multipart:
	@printf %60s | tr ' ' '-' && echo ''
	@echo ' some random data' > file.txt
	@echo '## $@ ##'
	@curl -v \
 -F "file=@file.txt" \
 "$(Address)/upload"


.PHONY: route-post-entry
route-post-entry:
	@echo '## $@ ##'
	@curl -v  \
 -H Expect: \
 -H "Transfer-Encoding: chunked" \
 -H "Content-Type: application/json" \
 -H "Accept: application/json" \
 -d '{"h":"entry"}' \
 $(Address)/micropub 
	@printf %60s | tr ' ' '-' && echo ''



.PHONY: route-mp
route-mp:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -v  "$(Address)/markup.nz/micropub?h=entry&content=Hello" | jq '.'
	@echo && printf %60s | tr ' ' '-' && echo ''

.PHONY: route-post-html-form
route-post-html-form:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -v  \
 -H "Accept: application/json" \
 -d "content='CONTENT'" \
 -d "h='entry'" \
 "$(Address)/markup.nz/micropub" \
 | jq '.'
	@echo && printf %60s | tr ' ' '-' && echo ''


.PHONY: check-can-set-restXQ-routes
check-can-set-restXQ-routes:
	@echo '## $@ ##'
	@echo ' -  compile restXQ function to run on the beam'
	@$(EVAL) 'xqerl:compile("/tmp/rest.xq")'
	@echo ' -  use restXQ defined endpoint to insert data in db'
	@curl -v $(Address)/insert
	@echo && printf %60s | tr ' ' '=' && echo ''

check-can-GET-restXQ-route:
	@printf %60s | tr ' ' '-' && echo ''
	@echo '## $@ ##'
	@curl -s $(Address) | grep -oP '<th>(.+)</th>'
	@printf %60s | tr ' ' '-' && echo ''
	@curl -s $(Address)/route/detail?id=a | grep -oP '<th>(.+)</th>'


check-can-use-file:
	@$(EVAL) 'xqerl:run("file:current-dir()").'
	@$(EVAL) 'xqerl:run("\"/tmp/small.xml\" => file:path-to-uri() => fn:unparsed-text-available( )").'
	@$(EVAL) 'xqerl:run(" \
 (\"/tmp/small.xml\"  => \
 file:read-text() => \
 fn:parse-xml()) instance of document-node() \
 ").'
	@$(EVAL) 'xqerl:run(" \
 (\"/tmp/small.xml\"  => \
 file:read-text() => \
 fn:parse-xml())/* instance of element() \
 ").'
	@$(EVAL) 'xqerl:run(" \
 (\"/tmp/small.xml\"  => \
 file:read-text() => \
 fn:parse-xml())/*/string() \
 ").'
	@$(EVAL) 'xqerl:run(" \
 (\"/tmp/small.xml\"  => \
 file:read-text() => \
 fn:parse-xml())/* => fn:innermost() \
 ").'
	@$(EVAL) 'xqerl:run(" \
 (\"/tmp/small.xml\"  => \
 file:read-text() => \
 fn:parse-xml())/* => fn:local-name() \
 ").'
	@$(EVAL) 'xqerl:run(" \
 \"/tmp/small.xml\"  => \
 file:path-to-uri() \
 ").'


#.PHONY: info
#info:
#	@echo -n '- IP address: '
#	@docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(XQN) 
#	@printf %60s | tr ' ' '-' && echo
#	@docker ps --filter name=$(XQN) --format ' -    name: {{.Names}}'
#	@docker ps --filter name=$(XQN) --format ' -  status: {{.Status}}'
#	@echo -n '-    port: '
#	@docker ps --format '{{.Ports}}' | grep -oP '^(.+):\K(\d{4})'
#	@#docker volume list   --format ' -  volume: {{.Name}}'
#	@#docker network list --filter name=$(NETWORK) --format ' - network: {{.Name}}'
#	@echo -n '- started: '
#	@$(EVAL) 'application:ensure_all_started(xqerl).'
#	@printf %60s | tr ' ' '-' && echo
#	@docker exec $(XQN) du -h -d 1 .
#	@printf %60s | tr ' ' '-' && echo
#	@docker exec $(XQN) ldd ./erts-10.5.1/bin/beam.smp
#	@printf %60s | tr ' ' '-' && echo
#	@docker exec $(XQN) printenv
#	@printf %60s | tr ' ' '-' && echo
#	@docker exec $(XQN) which xqerl
#	@printf %60s | tr ' ' '-' && echo
#	@#docker exec $(XQN) ldd ./lib/asn1-5.0.9/priv/lib/asn1rt_nif.so

#check-can-run-expression:
#	@printf %60s | tr ' ' '=' && echo 
#	@echo '## $@ ##'
#	@echo ' - run a xQuery expression'
#	@$(EVAL) \
# 'xqerl:run("xs:token(\"cats\"), xs:string(\"dogs\"), true() ").' | grep -oP '^\[\{xq.+$$'

#check-copy-into-container:
#	@printf %60s | tr ' ' '=' && echo 
#	@echo '## $@ ##'
#	@#docker exec $(XQN) rm -fr /tmp/
#	@docker cp fixtures $(XQN):/tmp
#	docker exec $(XQN) ls /tmp/fixtures
#	@#docker exec $(XQN) rm -rf /tmp/fixtures

#check-can-compile:
#	@printf %60s | tr ' ' '-' && echo 
#	@echo '## $@ ##'
#	@echo ' - compile an xQuery file'
#	@echo '   should return name of compiled file'
#	$(EVAL) 'xqerl:compile("./fixtures/example.xq")'
#	@printf %60s | tr ' ' '-' && echo 
#	@echo ' - compile an xQuery file then run query'
#	@echo '   should return query result'
#	$(EVAL) 'io:format(xqerl:run(xqerl:compile("./fixtures/example.xq")))'



#check-can-use-node-to-xml:
#	@echo '## $@ ##'
#	@echo ' - compile an xQuery file then run query'
#	@echo '   should output xml, should be able to then grep title'
#	@$(EVAL) "xqerl:compile(\"./fixtures/queries/sudoku2.xq\")."


#xxxxx:
#	@#echo ' - compile, run then grep the title'
#	@#$(EVAL) 'S = xqerl:compile("./fixtures/queries/sudoku2.xq"),xqerl_node:to_xml(S:main(#{})).' | grep -oP '<title>(.+)</title>'
#	@printf %60s | tr ' ' '=' && echo 
#	@# $(EVAL) 'S = xqerl:compile("./fixtures/sudoku2.xq"),io:format(xqerl_node:to_xml(S:main(#{}))).'

## | grep -oP '<title>(.+)</title>'

## fn:parse-xml-fragment($arg as xs:string?) 
##'xqldb_dml:insert_doc("http://xqerl.org/my_doc.xml","/tmp/fixtures/functx_order.xml").' || true
#.PHONY: db-can-insert
#db-can-insert:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@echo ' - insert XML document into database'
#	@$(EVAL) 'xqldb_dml:insert_doc("http://xqerl.org/my_doc.xml","./fixtures/small.xml").'


#.PHONY: db-can-delete
#db-can-delete:
#	@echo ' -  delete document in database'
#	$(EVAL) 'xqldb_dml:delete_doc("http://xqerl.org/my_doc.xml").'
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo ' -  try to fetch from database, the deleted document'
#	@echo '    should throw an error'
#	$(EVAL) 'io:format(xqerl_node:to_xml(xqerl:run(\"doc('http://xqerl.org/my_doc.xml')\"))).'
#	@printf %60s | tr ' ' '=' && echo ''


#.PHONY: routes
#routes:
#	@echo '## $@ ##'
#	@echo ' -  compile restXQ function to run on the beam'
#	@$(EVAL) 'xqerl:compile("./fixtures/queries/restXQ.xqm")'

#.PHONY: route-landing
#route-landing:
#	@printf %60s | tr ' ' '=' && echo
#	@echo ' restXQ exposes http URL endpoint'
#	@echo ' - curl: GET landing page'
#	@curl -v $(Address)/landing
#	@echo; printf %60s | tr ' ' '=' && echo

#.PHONY: route-get-landing
#route-get-landing:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@#curl -v $(Address)/markup.nz/landing
#	@echo '## $@ ##'
#	@w3m -dump $(Address)/markup.nz/landing

#.PHONY: route-params
#route-params:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@curl -v "$(Address)/params?h=entry&content=Burn+Out" | jq '.'

#.PHONY: route-alt-params
#route-alt-params:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@curl -v -G \
# --data "h=entry" \
# --data-urlencode "content=Insomniac Rust" \
# "$(Address)/params" | jq '.'

#.PHONY: route-head
#route-head:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@curl -v --head "$(Address)/"

#.PHONY: route-options
#route-options:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@curl -v -X OPTIONS "$(Address)/" | jq '.'

#.PHONY: route-form-multipart
#route-form-multipart:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo ' some random data' > file.txt
#	@echo '## $@ ##'
#	@curl -v \
# -F "file=@file.txt" \
# "$(Address)/upload"

#.PHONY: route-post-entry
#route-post-entry:
#	@echo '## $@ ##'
#	@curl -v  \
# -H Expect: \
# -H "Transfer-Encoding: chunked" \
# -H "Content-Type: application/json" \
# -H "Accept: application/json" \
# -d '{"h":"entry"}' \
# $(Address)/micropub 
#	@printf %60s | tr ' ' '-' && echo ''


#.PHONY: route-mp
#route-mp:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@curl -v  "$(Address)/markup.nz/micropub?h=entry&content=Hello" | jq '.'
#	@echo && printf %60s | tr ' ' '-' && echo ''

#.PHONY: route-post-html-form
#route-post-html-form:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@curl -v  \
# -H "Accept: application/json" \
# -d "content='CONTENT'" \
# -d "h='entry'" \
# "$(Address)/markup.nz/micropub" \
# | jq '.'
#	@echo && printf %60s | tr ' ' '-' && echo ''


#.PHONY: check-can-set-restXQ-routes
#check-can-set-restXQ-routes:
#	@echo '## $@ ##'
#	@echo ' -  compile restXQ function to run on the beam'
#	@$(EVAL) 'xqerl:compile("/tmp/rest.xq")'
#	@echo ' -  use restXQ defined endpoint to insert data in db'
#	@curl -v $(Address)/insert
#	@echo && printf %60s | tr ' ' '=' && echo ''

#check-can-GET-restXQ-route:
#	@printf %60s | tr ' ' '-' && echo ''
#	@echo '## $@ ##'
#	@curl -s $(Address) | grep -oP '<th>(.+)</th>'
#	@printf %60s | tr ' ' '-' && echo ''
#	@curl -s $(Address)/route/detail?id=a | grep -oP '<th>(.+)</th>'


#check-can-use-file:
#	@$(EVAL) 'xqerl:run("file:current-dir()").'
#	@$(EVAL) 'xqerl:run("\"/tmp/small.xml\" => file:path-to-uri() => fn:unparsed-text-available( )").'
#	@$(EVAL) 'xqerl:run(" \
# (\"/tmp/small.xml\"  => \
# file:read-text() => \
# fn:parse-xml()) instance of document-node() \
# ").'
#	@$(EVAL) 'xqerl:run(" \
# (\"/tmp/small.xml\"  => \
# file:read-text() => \
# fn:parse-xml())/* instance of element() \
# ").'
#	@$(EVAL) 'xqerl:run(" \
# (\"/tmp/small.xml\"  => \
# file:read-text() => \
# fn:parse-xml())/*/string() \
# ").'
#	@$(EVAL) 'xqerl:run(" \
# (\"/tmp/small.xml\"  => \
# file:read-text() => \
# fn:parse-xml())/* => fn:innermost() \
# ").'
#	@$(EVAL) 'xqerl:run(" \
# (\"/tmp/small.xml\"  => \
# file:read-text() => \
# fn:parse-xml())/* => fn:local-name() \
# ").'
#	@$(EVAL) 'xqerl:run(" \
# \"/tmp/small.xml\"  => \
# file:path-to-uri() \
# ").'

