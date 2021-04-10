`xq run {filename} {argument}` runs compiled xQuery with a external argument'

```
xq run turtles.xq turtles
xq run turtles.xq elephants
```

By convention `{filename}` is resolved to 
a main module with a `xq` extension `src/main_modules/{name}.xq`  

The file will be copied into the xqerl './code/src' directory of the running xq container.
The `code` directory is a mounted docker volume named `xqerl-compiled-code` 






