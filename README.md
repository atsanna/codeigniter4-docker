# codeigniter4-docker
[![Docker Build Status](https://img.shields.io/docker/cloud/build/atsanna/codeigniter4.svg?style=flat-square)](https://hub.docker.com/r/atsanna/codeigniter4/)

This repository provides you a development environment without requiring you to install PHP, a web server, and any other server software on your local machine. For this, it requires Docker and Docker Compose.

Basic example to create your container (tested on Ubuntu 18.04 - Docker version 19.03.5, build 633a0ea838):

**NOTE: This package is under early development and is not ready for prime-time.**

create this structure:
```
codeigniter/
    - conf/apache.conf
    - Dockerfile
    - startScript.sh
```    
    
Go to the codeigniter folder:
```
cd codeigniter
```

build the image:<br>
```
docker build . -t codeginiter:4.0.2
```

start the container:
```
docker container run --publish 80:80 --name ci4 -v /localfolder:/var/www/html codeginiter:4.0.2
```
