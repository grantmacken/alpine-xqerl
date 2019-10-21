module namespace route = 'http://xqerl.org/#route';

declare %private function route:render() {
    element html {
    element head {
    element title {
      text {'xqerl'}
     }
    },
    element body { 
        ``[hello from xqerl  `{'restXQ'}` ]``
        }
  }
};


declare 
  %rest:GET
  %rest:path('/landing')
  %output:method('html')
  %rest:produces('text/html')
function route:infoLanding() {
    route:render()
};


(:

curl -v -G \
 --data "h=entry" \
 --data-urlencode "content=Beam me up" \
 http://localhost:8081/params
:)
declare 
  %rest:GET
  %rest:path('/params')
  %rest:query-param("h", "{$h}", "")
  %rest:query-param("content", "{$content}", "")
  %rest:produces('application/json')
  %output:method('json')
function route:params($h, $content) {
map { "type": $h, "content": $content}
};

declare 
  %rest:HEAD
  %rest:path('/params')
  %rest:produces('application/json')
  %output:method('json')
function route:params() {
map { "type": "type", "content": "content"}
};

(:
curl -v \
 --data "h=entry" \
 --data-urlencode "content=Beam me up" \
 http://localhost:8081/form
:)

declare 
  %rest:POST
  %rest:path('/forms')
  %rest:form-param("h", "{$h}", "")
  %rest:form-param("content", "{$content}", "(no content)")
  %rest:produces('application/json')
  %output:method('json')
function route:myForm($h, $content) {
map { "type": $h, "content": $content}
};


(:
curl -v \
 --data "h=entry" \
 --data-urlencode "content=Beam me up" \
 http://localhost:8081/form


declare 
  %rest:DELETE
  %rest:path('/path/to/resource')
  %output:method('json')
function route:myDelete() {
map { "delete": "sss"}
};

declare 
  %rest:PUT("{$body}")
  %rest:path('/path/to/resource')
 %rest:consumes("application/x-www-form-urlencoded")
  %output:method('json')
function route:myPUT($body) {
map { "put": "sss"}
};

:)
