
Create a db link to preprocessed binary asset

```
# xq link {domain} {asset-path}
xq link example.com icons/article.svg'
```

all *asset* sources are located in the "./src/static_assets/" directory so 
the {asset-path} will be resolved as `./src/static_assets/icons/article.svg`

Before the asset is stored it can be pipelined thru *docker container 
instances* to get a preferred outcome. For static assets this outcome usually 
means some form file size reduction.


## preprocessing pipeline example

 1. article.svg => 
 2. scour => 
 3. zopfli => 
 4. article.svgz

 The result artifact is a gzipped svg file  with a svgz extension

## link outcome

```
xq link example.com icons/article.svg
```

The command will produce two outcomes.

1. a binary asset on the static-assets container volume. The static-assets 
container volume is mounted on the xqerl `priv/static` container directory.
 `priv/static/icons/article.svgz`
2. A domain based db `link` 

'http://example.com/icons/article' => 'file:///usr/local/xqerl/priv/static/icons/article.svgz'

## links are searchable db items

```
xq list http://example.com/icons
```



