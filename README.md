# WIP [alpine-xqerl](https://github.com/grantmacken/alpine-xqerl)

Pre-build images are available on [dockerhub](https://hub.docker.com/r/grantmacken/alpine-xqerl)

Test build on [travis-ci](https://travis-ci.org/grantmacken/alpine-xqerl)

[![Build Status](https://travis-ci.org/grantmacken/alpine-eXist.svg?branch=master)](https://travis-ci.org/grantmacken/alpine-xqerl)

 [xqerl](https://zadean.github.io/xqerl)
 maintained by 
 [Zachary Dean](https://github.com/zadean),
 is an Erlang XQuery 3.1 Processor and XML Database.

## fat playground and minimized deploy images

Note: To save typing, I use Make to create shortcut aliases.  e.g.

```
make run-shell
# shortcut for
# docker run -it grantmacken/alpine-xqerl:shell
```

1. *shell*: this is the fat (304MB) playground 'desktop' target.

```
make run-shell
```
  This starts xqerl from ENTRYPOINT `rebar3 shell` to pop you into
  the *interactive* erlang shell. 
  The container contains a clone the xqerl repo so from here you should be able to follow the 
  [Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md)
  tutorial from section 4 onwards.

TODO. cast


2. *min*: this is a minimal ( 52MB ) image , as small as I can get it, 'deploy' image.


[![asciicast](https://asciinema.org/a/264230.svg)](https://asciinema.org/a/264230)


```
# make network
# do only once
# make network creates a named bridge network, 
# which xq container will will join with ...
make up
# uses docker-compose to start container and join network
make check
# 
```



 


