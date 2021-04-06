declare variable $arg external;
declare variable $dbIO := QName("http://markup.nz/#err", 'dbIO');
(:~
 : xqerl db can store any XDM item type
 : @see https://github.com/zadean/xqerl/blob/main/src/xqerl_mod_db.erl
:)

declare 
%updating 
function local:store($item, $uri){
  db:put( $item, $uri )
}; 

try {

let $argPath := ('/tmp', $arg ) => string-join('/')
let $path := 
  if ( $argPath  => file:is-file() ) 
  then $argPath => file:path-to-uri() => string()
  else ( error( $dbIO, ``[ file [ `{$argPath}` ] not found  ]``))
let $name := $path => file:name()
let $ext := $name => substring-after('.')
let $base := $arg => substring-before( $name )
let $item :=
  switch ( $ext )
  case "svg" return $path => file:read-text()  => parse-xml()
  case "csv" return $path => file:read-text()  => csv:parse()
  case "json" return $path => fn:json-doc()
  default return error( $dbIO, ``[ [ `{$ext}` ] can not hande extension ]``)

let $getFuncType := function( $item as item()) as xs:string {
      if ($item instance of map(*)) then 'map'
 else if ($item instance of array(*)) then 'array'
 else 'function'
}

let $getItemType := function( $item as item() ) as xs:string {
 if ( $item instance of document-node() ) then 'node'
 else if ( $item instance of function(*) ) then $item => $getFuncType()
 else ('atomic' )
}

let $uriBase := 'http://' || $base || substring-before( $name, '.') || '.'
let $uri := 
  switch ( $ext )
    case "svg" return $uriBase => concat( $ext )
    case "xml" return $uriBase => concat( $ext )
    case "json" return $uriBase => concat( $item => $getItemType())
    default return   error( $dbIO, ``[ [ `{$ext}` ] can not hande extension ]``) 

return (
local:store($item, $uri)
,
``[ - ok: stored into db
 - item:     `{$item => $getItemType()}` 
 - location: `{$uri}` 
]``
  )
} catch * {
``[
  ERROR!
  module: `{$err:module}`
  line number: `{$err:line-number}`
 `{$err:code}`: `{$err:description}`
]``
}

