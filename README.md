# [alpine-xqerl](https://github.com/grantmacken/alpine-xqerl)

[![](https://github.com/grantmacken/alpine-xqerl/workflows/CI/badge.svg)](https://github.com/grantmacken/alpine-xqerl/actions)

 [xqerl](https://zadean.github.io/xqerl)
 maintained by 
 [Zachary Dean](https://github.com/zadean),
 is an Erlang XQuery 3.1 Processor and XML Database.

## recent updates
 - [x] built from [alpine 3.13.2](https://hub.docker.com/_/alpine) docker OS
 - [X] [OTP 23.2.5](https://www.erlang.org/news) latest release 
 - [x] built from latest xqerl 
 [merge commit](https://api.github.com/repos/zadean/xqerl/git/commits/1a94833e996435495922346010ce918b4b0717f2)
 - [x] uses config values in .env file to set some xqerl.config values. This is of interest only if you wish to build the image
   yourself. In xqerl repo the  `./config/xqerl.config`, item `environment_access` is set to `false`. Our docker image
   is built with this var set to `true`. If you want to keep the default, clone this repo and in the file `.env` set `CONFIG_ENVIRONMENT_ACCESS=true`, then run `make` to build the image.

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

## Shell: A Fat Playground Desktop Image

```
docker run -it --rm grantmacken/alpine-xqerl:shell
```

This starts xqerl from ENTRYPOINT `rebar3 shell` to pop you into
the *interactive* erlang shell. 
The container contains a clone the  [xqerl repo](https://zadean.github.io/xqerl) so from here you should be able to follow the 
[Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md)
tutorial from section 4 onwards.

If you have a OS with 'systemd' init system (i.e. most modern linux OS),
you may also want to view the xqerl logged output from the container. 

```
docker network create --driver=bridge wrk
docker run \
  -it --rm \
  --name xqShell \
  --publish 8081:8081 \
  --log-driver=journald \
  --network wrk
  ```

Now in the erlang shell, as you work through the [Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md) tutorial,
in another terminal you can follow the container logged output, by using the following command.

```
sudo journalctl -b CONTAINER_NAME=xqShell --all -f
```

## Smallish Internet Deployable Image

This is a smallish (about 42MB) 'deploy' image, where a binary executable boots the xqerl environment,

 Prior to running the container, I suggest you create a docker **network** and some docker **volumes**.
Creating a prior *network*, allows a running xqerl container to join a network rather than creating a new network each time the container is started.

Created docker *volumes* allow us to persist our 'xquery code' and any data in the 'xqerl database'. 
We could mount bind, to a local directory, but created named volumes are more portable.

```
docker network create --driver=bridge wrk
docker volume  create --driver=local --name xqerl-compiled-code
docker volume  create --driver=local --name xqerl-database
```

Once the docker network and volumes are in place we can run the container.

```
docker run \
 --rm \
 --name xq \
 --mount type=volume,target=/usr/local/xqerl/code,source=xqerl-compiled-code \
 --mount type=volume,target=/usr/local/xqerl/data,source=xqerl-database \
 --publish 8081:8081 \
 --network wrk \
 --detatch \
 --publish 8081:8081 \
 grantmacken/alpine-xqerl
```

# Using docker-compose

Perhaps the easiest way to use this image is through docker-compose.
I have provided and example 'docker-compose.yml' and '.env' 
which you can copy/clone and modify to use to boot your xqerl project.

The docker-compose run time environment includes
* A container name 'xq'
* Two persistent docker volumes 
    1. A volume named 'data' which holds the database data
    2. A volume name 'code' which holds the compiled xQuery  beam files 
* A network named 'www' 
* A port published on 8081

In my docker-compose the running container attaches to a pre-existing 
named network, so you will need to create that first. 
You only need to do this once
 
```
docker network create --driver=bridge wrk
```

Now to bring the container up.

```
docker-compose up -d
```

Once the container is up running, you can issue 
docker exec commands, like this ...

```
docker exec xq ./bin/xqerl eval 'application:ensure_all_started(xqerl).'
docker exec xq ./bin/xqerl eval "xqerl:run(\"xs:token('cats'), xs:string('dogs'), true() \")."
```

The above is not to very useful, so to really get started the thing first things you need to check out, 
is the [xqerl documentation](https://zadean.github.io/xqerl/).
There you will learn how how to ...
- compile your xquery files so they run on the [OTP beam](https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine))
- store update and retrieve data from the xqerl database
- use restXQ to create a restful web facing applications and APIs

The following cast 
1. brings the container up `docker-compose up -d`
2. runs various docker commands like `docker ps --filter name=xq --format ' -  status: {{.Status}}'`
3. runs `docker exec xq` commands
4. brings down the container  `docker-compose down`

[![asciicast](https://asciinema.org/a/264230.svg)](https://asciinema.org/a/264230)









 


