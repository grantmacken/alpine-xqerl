declare variable $arg external;
(:~
 : xqerl db can store any XDM item type
 : get the item from the db and see what type it is
:)
try {
(: @see https://www.w3.org/TR/xpath-datamodel-31/#types-hierarchy :)
let $durationType := function( $item as xs:duration ) as xs:string {
 if ($item instance of xs:dayTimeDuration) then 'xs:dayTimeDuration'
 else if ($item instance of xs:yearMonthDuration) then 'xs:yearMonthDuration'
 else 'xs:duration'
}

let $integerType := function( $item as xs:integer ) as xs:string {
 if ( $item instance of xs:nonPositiveInteger ) then 'TODO'
 else if ( $item instance of xs:long ) then 'TODO'
 else if ( $item instance of xs:nonNegativeInteger ) then 'TODO'
 else 'xs:integer'
}

let $decimalType := function( $item as xs:decimal ) as xs:string {
 if ($item instance of xs:integer ) then $item => $integerType()
 else 'xs:decimal'
}

let $tokenType := function( $item as 	xs:token ) as xs:string {
 'TODO xs:token'
}

let $stringType := function( $item as xs:string ) as xs:string {
  if ( $item instance of xs:normalizedString ) then 
    if ( $item instance of xs:token ) then  $item => $tokenType()
    else 'xs:normalizedString'
  else 'xs:string'
}

let $atomicType := function( $item as xs:anyAtomicType* ) as xs:string {
 if ($item instance of xs:untypedAtomic) then 'xs:untypedAtomic'
(: date - time :)
 else if ($item instance of xs:date) then 'xs:date'
 else if ($item instance of xs:time) then 'xs:time'
 else if ($item instance of xs:dateTime) then 
    if ( $item instance of xs:dateTimeStamp ) then 'xs:dateTimeStamp'
    else 'xs:dateTime'
 else if ($item instance of xs:anyURI) then 'xs:anyURI'
 (: strings TODO :)
 else if ($item instance of xs:string) then $item => $stringType()
 else if ($item instance of xs:QName) then 'xs:QName'
 else if ($item instance of xs:boolean) then 'xs:boolean'
 else if ($item instance of xs:base64Binary) then 'xs:base64Binary'
 else if ($item instance of xs:hexBinary) then 'xs:hexBinary'
 (: numbers :)
 else if ($item instance of xs:float) then 'xs:float'
 else if ($item instance of xs:double) then 'xs:double'
 else if ($item instance of xs:decimal) then $item => $decimalType()

 else if ($item instance of xs:duration) then $item => $durationType()
 else if ($item instance of xs:gYearMonth) then 'xs:gYearMonth'
 else if ($item instance of xs:gYear) then 'xs:gYear'
 else if ($item instance of xs:gMonthDay) then 'xs:gMonthDay'
 else if ($item instance of xs:gDay) then 'xs:gDay'
 else if ($item instance of xs:gMonth) then 'xs:gMonth'
 else ()
}

let $nodeKind := function( $node as node() ) as xs:string {
 if ($node instance of element()) then 'element'
 else if ($node instance of attribute()) then 'attribute'
 else if ($node instance of text()) then 'text'
 else if ($node instance of document-node()) then 'document-node'
 else if ($node instance of comment()) then 'comment'
 else if ($node instance of processing-instruction()) then 'processing-instruction'
 (: should include namespace? :)
 else ()
}

let $funcType := function( $item as item()) as xs:string {
      if ($item instance of map(*)) then 'map'
 else if ($item instance of array(*)) then 'array'
 else 'function'
}

let $itemType := function( $item as item() ) as xs:string {
 if ( $item instance of node() ) then $item => $nodeKind()
 else if ( $item instance of function(*) ) then $item => $funcType()
 else if ( $item instance of xs:anyAtomicType ) then 'atomic' (: TODO :)
 else ( )
   (:throw err:)
}

return $arg => db:get()  => $itemType()

} catch * {
``[
  ERROR! 
  module: `{$err:module}`
  line number: `{$err:line-number}`
 `{$err:code}`: `{$err:description}`
]``
}

