# [alpine-xqerl](https://github.com/grantmacken/alpine-xqerl)

[![](https://github.com/grantmacken/alpine-xqerl/workflows/CI/badge.svg)](https://github.com/grantmacken/alpine-xqerl/actions)

 [xqerl](https://zadean.github.io/xqerl)
 maintained by 
 [Zachary Dean](https://github.com/zadean),
 is an Erlang XQuery 3.1 Processor and XML Database.

## Recent Updates
 - [x] built from [alpine 3.13.4](https://hub.docker.com/_/alpine) docker OS
 - [x] [OTP 23.3.1](https://hub.docker.com/_/erlang) latest [release](https://github.com/erlang/otp/releases)
 - [x] built from latest xqerl 
 [merge commit](https://api.github.com/repos/zadean/xqerl/git/commits/1a94833e996435495922346010ce918b4b0717f2)
 - [x] uses config values in .env file to set some xqerl.config values. This is of interest only if you wish to build the image
   yourself. In xqerl repo the  `./config/xqerl.config`, item `environment_access` is set to `false`. Our docker image
   is built with this var set to `true`. If you want to keep the default, clone this repo and in the file `.env` set `CONFIG_ENVIRONMENT_ACCESS=false`, then run `make` to build the image.
  - [x] in container added tzdata for timezone resolution
  - [x] bin dir contains a [cli for xqerl](./docs/images/rec-xq-db.svg)

[xqerl](https://zadean.github.io/xqerl) is in constant development, 
so I have also tagged images with the xqerl [main](https://github.com/zadean/xqerl) git commit sha.  These tagged images are available on [dockerhub](https://hub.docker.com/r/grantmacken/alpine-xqerl/tags)
If you are testing or setting up a xqerl development environment, then it is advisable to use the latest sha tagged images.
Any [xqerl issues](https://zadean.github.io/xqerl/issues) when developing with xqerl can be communicated back to the [repo owner](https://github.com/zadean) using the commit sha as a reference.

```
docker pull grantmacken/alpine-xqerl:1a94833e996435495922346010ce918b4b0717f2
```

Other pre-built images are available on [dockerhub](https://hub.docker.com/r/grantmacken/alpine-xqerl)
The latest xqerl docker release is also on [github packages](https://github.com/grantmacken/alpine-xqerl/packages)

On [dockerhub](https://hub.docker.com/r/grantmacken/alpine-xqerl) I have provided two images
 
1. interactive erlang shell: This image is a clone of xqerl repo with the entry point via `rebar3 shell` 
2. production release: a smallish internet deploy image

## Notes: working with xqerl

This repo provides some helper **tools**, 
to help with you to work with xqerl

1. *Makefile* at the project root.
2. *xq* which is a bash cli executable in the 'bin' directory. 
3. a src directory, which is an example xqerl project layout.

## Shell: A Fat Playground Desktop Image

```
make run-shell
```

This starts xqerl from ENTRYPOINT `rebar3 shell` to pop you into
the *interactive* erlang shell. 
The container contains a clone the  [xqerl repo](https://zadean.github.io/xqerl) so from here you should be able to follow the 
[Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md)
tutorial from section 4 onwards.

## Smallish Internet Deployable Image

This is a smallish (about 42MB) 'deploy' image, where a binary executable boots the xqerl environment,

 Prior to running the container, I suggest you create a docker **network** and some docker **volumes**.
Creating a prior *network*, allows a running xqerl container to join a network rather than creating a new network each time the container is started.

Created docker *volumes* allow us to persist our 'xquery code' and any data in the 'xqerl database'. 
We could mount bind, to a local directory, but created named volumes are more portable.
Once the docker network and volumes are in place we can run the container.

In the Makefile I have an `make up` and `make down` target,
which sets this up for you using some config vars from the .env file

The docker run time instance includes 
* A container run name: 'xq'
* A container hostname: 'xq'
* Two persistent docker volumes 
    1. A volume named 'data' which holds the xqerl database data
    2. A volume name 'code' which holds the xqerl compiled xQuery  beam files 
* joining docker network named 'wrk'
* uses docker host environment variable `TZ` for setting local timezones
* exposes published port: 8081

Once the container is up running, you can issue 
docker exec commands, like this ...

```
docker exec xq xqerl eval 'application:ensure_all_started(xqerl).'
docker exec xq xqerl eval "xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \")."
```

The above is not to very useful, so to really get started the thing first things you need to check out, 
is the [xqerl documentation](https://zadean.github.io/xqerl/).
There you will learn how how to ...
- compile your xquery files so they run on the [OTP beam](https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine))
- store update and retrieve data from the xqerl database
- use restXQ to create a restful web facing applications and APIs













 


