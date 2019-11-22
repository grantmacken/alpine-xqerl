# [alpine-xqerl](https://github.com/grantmacken/alpine-xqerl)

Pre-built images are available on [dockerhub](https://hub.docker.com/r/grantmacken/alpine-xqerl)

```
docker pull grantmacken/alpine-xqerl
```


<!--
-->


[![](https://github.com/grantmacken/alpine-xqerl/workflows/CI/badge.svg)](https://github.com/grantmacken/alpine-xqerl/actions)

 [xqerl](https://zadean.github.io/xqerl)
 maintained by 
 [Zachary Dean](https://github.com/zadean),
 is an Erlang XQuery 3.1 Processor and XML Database.



#Intro

TODO!


## Available Alpine Images 

1. shell: a clone of xqerl repo with the entry point via `rebar3 shell` 
2. production release: a smallish production ready deploy image

## Shell: A Fat Playground Desktop Image

There is image is tagged 'shell'

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
docker run \
  -it --rm \
  --name xqShell \
  --publish 8081:8081 \
  --log-driver=journald \
  grantmacken/alpine-xqerl:shell
```

Now in the erlang shell, as you work through the [Getting Started](https://github.com/zadean/xqerl/blob/master/docs/src/GettingStarted.md) tutorial,
in another terminal you can follow the container logged output, by using the following command.

```
sudo journalctl -b CONTAINER_NAME=xqShell --all -f
```

## Smallish Deploy Image

```
docker pull grantmacken/alpine-xqerl
```

This is a smallish (42.3MB) 'deploy' image, where a binary executable boots the xqerl environment,

```
ENTRYPOINT ["./bin/xqerl","foreground" ]
```

[xqerl](https://zadean.github.io/xqerl) is in constant development, so I have also tagged images with the [master](https://github.com/zadean/xqerl) commit sha.  These tagged images are available on [dockerhub](https://hub.docker.com/r/grantmacken/alpine-xqerl/tags)
If you are testing or setting up a xqerl development environment, then it is advisable to use the latest sha tagged images.
Any [xqerl issues](https://zadean.github.io/xqerl/issues) when developing with xqerl can be communicated back to the repo owner using the commit sha as a reference.


# Setting up a xqerl dev environment

Perhaps the easiest way to use this image is through docker-compose.
I have provided and example 'docker-compose.yml' and '.env' 
which you can copy/clone and modify to use to boot your xqerl project.

The docker-compose run time environment includes
* A container name 'xq'
* Two persistent docker volumes 
    1. A volume named 'xqData' which holds the database data
    2. A volume name 'xqCode' which holds the compiled xQuery  beam files 
* A network named 'www' 
* A port published on 8081

In my docker-compose the running container attaches to a pre-existing 
named network, so you will need to create that first. 
You only need to do this once
 
```
docker network create --driver=bridge www
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

The following cast 
1. brings the container up `docker-compose up -d`
2. runs various docker commands like `docker ps --filter name=xq --format ' -  status: {{.Status}}'`
3. runs `docker exec xq` commands
4. brings down the container  `docker-compose down`

[![asciicast](https://asciinema.org/a/264230.svg)](https://asciinema.org/a/264230)









 


