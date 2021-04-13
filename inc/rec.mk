
.PHONY: visit
visit: 
	@echo 'firefox --newwindow https://$(REPO_OWNER).github.io/$(REPO_NAME)'
	@firefox https://$(REPO_OWNER).github.io/$(REPO_NAME)

.PHONY: pr-create
pr-create: 
	gh pr create --help
	gh pr create --fill

.PHONY: pr-merge
pr-merge: 
	gh pr merge --help
	gh pr merge -s -d
	git pull


.PHONY: rec-xq-db
rec-xq-db:
	@svg-term \
 --out docs/images/$(@).svg \
 --width 80 \
 --command="\
echo ' - xq actions ' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo \"> xq \" && \
sleep 1 && xq && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - xq database actions [ put link available list get delete ] ' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 && echo '  \"xq put {data-path}\"  will store a data source as a db XDM item' && \
sleep 1 && echo '  all *data* sources are located in the \"./src/data/\" directory' && \
echo '> xq put example.com/usecase/employees.xml' && \
sleep 1 && xq put example.com/usecase/employees.xml && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 && echo '> xq put example.com/usecase/colors.json' && \
sleep 1 && xq put example.com/usecase/colors.json && \
sleep 1 && echo '> xq put example.com/usecase/mildred.json' && \
sleep 1 && xq put example.com/usecase/mildred.json  && \
sleep 1 && printf %60s | tr ' ' '='  && echo && \
sleep 1 && echo '  \"xq link {domain} {path}\" will store a db link to a static asset file' && \
sleep 1 && echo '  the {domain} arg is the database name' && \
sleep 1 && echo '  the {path} arg is path to the source file' && \
sleep 1 && echo '  all *link* sources are located in the \"./src/static_assets\" directory' && \
sleep 1 && echo '> xq link example.com icons/article.svg'  && \
sleep 1 && xq link example.com icons/article.svg  && \
sleep 1 && echo '> xq link example.com icons/note.svg'  && \
sleep 1 && xq link example.com icons/note.svg  && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 &&  echo '  \"xq available {db-path}\" returns true or false' && \
sleep 1 &&  echo '> xq available example.com/usecase/colors.array' && \
sleep 1 && xq available example.com/usecase/colors.array  && \
sleep 1 &&  echo '> xq available example.com/usecase/nothing.array' && \
sleep 1 && xq available example.com/usecase/nothing.array && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 &&  echo '  \"xq list {db-path}\" lists db items and db links' && \
echo \"> xq list example.com/usecase \" && \
sleep 1 && xq list example.com/usecase && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo \"> xq list example.com/icons \" && \
sleep 1 && xq list example.com/icons && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 &&  echo '  \"xq get {db-path}\" returns a serialized XDM item' && \
sleep 1 &&  echo '  document-node XDM items will be serialized as XML strings' && \
sleep 1 && echo \"> xq get example.com/usecase/employees.xml \" && \
sleep 1 && xq get example.com/usecase/employees.xml && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 && echo ' array and map XDM items will be serialized as JSON strings' && \
sleep 1 &&  echo '> xq get example.com/usecase/colors.array' && \
sleep 1 &&  xq get example.com/usecase/colors.array && \
sleep 1 &&  echo '> xq get example.com/usecase/mildred.map' && \
sleep 1 &&  xq get example.com/usecase/mildred.map && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 &&  echo '  \"xq delete {db-path}\" deletes a db item or db link' && \
sleep 1 && echo \"> xq delete example.com/usecase/employees.xml \" && \
sleep 1 && xq delete example.com/usecase/employees.xml && \
sleep 1 && printf %60s | tr ' ' '='"
	@#cat ../tmp/$(@).cast | svg-term --out docs/$(@).svg --window
	@firefox --new-tab docs/images/$(@).svg

.PHONY: rec-xq-req
rec-xq-req:
	@mkdir -p ../tmp
	@asciinema rec ../tmp/$(@).cast \
 --overwrite \
 --title='xq req: fetch a HTML doc, apply xpath expression'\
 --idle-time-limit 5 \
 --command="\
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo '  \"xq req {uri} {xpath expression}\" fetch a HTML doc, apply xpath expression'  && sleep 1 && \
sleep 3 && printf %60s | tr ' ' '-'  && echo && \
echo '  example: fetch http://example.com and get the html element'  && sleep 1 && \
echo '> xq req http://example.com \"/*\"'  && \
xq req 'https://example.com' '/*' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 3 && clear && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 && echo '  use complex xpath 3.1 xpath expressions' && \
sleep 1 && echo '  that include the \"!\" or \"=>\" operators' && \
echo '  example: fetch wikipedia XPath page and get the xPath commandline tools'  && sleep 1 && \
echo '  and use the bang operator to create a numbered list'  && sleep 1 && \
echo '> xq req https://en.wikipedia.org/wiki/XPath\\' && sleep 1 && \
echo '> //*[./*/@id=\"Command-line_tools\"]/following-sibling::ul[1]/li/string()\\' && sleep 1 && \
echo '> !concat(position(),\":\",\"&#9;\",./string(),\"&#10;\")' && sleep 1 && \
xq req 'https://en.wikipedia.org/wiki/XPath' \
'//*[./*/@id=\"Command-line_tools\"]/following-sibling::ul[1]/li \
! concat(position(),\":\",\"&#9;\",./string(),\"&#10;\")' && sleep 1 && \
sleep 1 && printf %60s | tr ' ' '-'  && echo &&  \
sleep 3 && clear && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo '  example: fetch the xpath-functions-31 page and'  && sleep 1 && \
echo '  use the arrow operator to create a sorted list'  && sleep 1 && \
echo '> xq req https://www.w3.org/TR/xpath-functions-31' && sleep 1 && \
echo '> /html/body/nav//span[@class=\"content\"]\\' && sleep 1 && \
echo '> [matches(.,\"^(fn|op|map|array|math):\")]/string()\\' && sleep 1 && \
echo '> =>sort()=>string-join(\"&#10;\")' && \
xq req 'https://www.w3.org/TR/xpath-functions-31' \
'/html/body/nav//span[@class=\"content\"]\
[matches(.,\"^(fn|op|map|array|math):\")]/string()\
=> sort() => string-join(\"&#10;\")' && \
sleep 3 && printf %60s | tr ' ' '='  && echo"
	asciinema upload ../tmp/$@.cast

.PHONY: rec-xq-lookup
rec-xq-lookup:
	@mkdir -p ../tmp
	@asciinema rec ../tmp/$(@).cast \
 --overwrite \
 --title='xq lookup: fetch a json doc, apply lookup expression'\
 --idle-time-limit 5 \
 --command="\
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo '  xq req {uri} {lookup expression} ' && sleep 1 && \
echo '  fetch a JSON doc, apply lookup expression'  && sleep 1 && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo 'example: get the latest commit sha to the zadean/xqerl repo'  && sleep 1 && \
echo '> xq lookup \\'  && sleep 1 && \
echo '> https://api.github.com/repos/zadean/xqerl/git/refs/heads/main \\'  && sleep 1 && \
echo '> ?object?sha'  && sleep 1 && \
xq lookup https://api.github.com/repos/grantmacken/alpine-xqerl/git/refs/heads/main ?object?sha && sleep 1 && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo 'example: get a list of public apis' && sleep 1 && \
echo '> xq lookup \\'  && sleep 1 && \
echo '> https://api.publicapis.org/entries \\'  && sleep 1 && \
echo '> ?entries?*?API=>sort()=>string-join(\"&#10;\")' && sleep 1 && \
xq lookup https://api.publicapis.org/entries \"?entries?*?API=>sort()=>string-join('&#10;')\" && \
sleep 3 && printf %60s | tr ' ' '='  && echo"
	asciinema upload ../tmp/$@.cast

.PHONY: rec-xq
rec-xq:
	@mkdir -p ../tmp
	@asciinema rec ../tmp/$(@).cast \
 --overwrite \
 --title='xq - a cli for xqerl'\
 --idle-time-limit 1 \
 --command="\
echo ' - xQuery actions [ query | compile | run ] ' && \
sleep 1 && printf %60s | tr ' ' '='  && echo && \
echo \"> xq compile turtles.xq\" && \
sleep 1 && xq compile turtles.xq && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo \"> xq run turtles.xq turtles\" && \
sleep 1 && xq run turtles.xq turtles && \
echo \"> xq run turtles.xq elephants\" && \
sleep 1 && xq run turtles.xq elephants && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - application [ call | eval ] run xqerl application expressions' && \
echo \"> xq call xqldb_db_server exists http://example.com\" && \
sleep 1 && xq call xqldb_db_server exists http://example.com && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo \"> xq eval 'erlang:node().'\" && \
sleep 1 && xq eval 'erlang:node().' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo \"> xq eval 'erlang:node().'\" && \
sleep 1 && xq eval 'erlang:node().' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo \"> xq eval 'erlang:get_cookie().'\" && \
sleep 1 && xq eval 'erlang:get_cookie().' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - shell action [ sh ] run alpine busybox shell commands ' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo \"> xq sh 'date -I'\" && \
sleep 1 && xq sh 'date -I' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo"
	@cat ../tmp/$(@).cast | svg-term  --out ../tmp/$(@).svg
	@firefox --new-tab ../tmp/$(@).svg


.PHONY: rec-up
rec-up:
	@mkdir -p ../tmp
	@asciinema rec ../tmp/$(@).cast \
 --overwrite \
 --title='run xqerl instance in a docker container'\
 --idle-time-limit 1 \
 --command="\
sleep 1 && printf %60s | tr ' ' '='  && echo && \
echo ' - start the container ... ' && \
make --silent up  && echo && \
sleep 1 && printf %60s | tr ' ' '-'  && echo"
	@#cat ../tmp/$(@).cast | svg-term > ../tmp/$(@).svg
	@#firefox --new-tab ../tmp/$(@).svg


.PHONY: rec-init
rec-init:
	@npm install -g asciicast-to-svg
	@npm install -g svg-term-cli
	
.PHONY: rec-to-svg
rec-to-svg:
	@cat ../tmp/up.cast | svg-term > ../tmp/up.svg
	@firefox --new-tab ../tmp/up.svg
	#w3m -dump ../tmp/up.svg



PHONY: play
play:
	@asciinema play ../tmp/rec-xq-req.cast

.PHONY: upload
upload:
	asciinema upload ../tmp/up.cast


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

