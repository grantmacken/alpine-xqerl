# alpine-xqerl
 
Maintained by [Zachary Dean](https://github.com/zadean) 
[xqerl](https://zadean.github.io/xqerl) is an Erlang XQuery 3.1 Processor and XML Database.


This WIP is my attempt to dockerize xqerl.

Why: TODO

## fat playground and slim deploy targets

Note: To save typing, I use Make to create shortcut aliases

```
make run-shell
# shortcut for
# docker run -it grantmacken/alpine-xqerl:shell
```

1. *shell*: this is the fat playground 'desktop' target.

```
make run-shell
```
  This starts xqerl from ENTRYPOINT `rebar3 shell` to pop you into
  the *interactive* erlang shell. 
  The container contains a clone the xqerl repo so from here you should be able to follow the 
  [Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md)
  tutorial from section 4 onwards.

TODO. cast


2. *min*: this is a minimal, as small as I can get it, 'deploy' target

```
# make network
# do only once
# make network creates a named bridge network, 
# which xq container will will join with ...
make up
# uses docker-compose to start container and join network
```



 


