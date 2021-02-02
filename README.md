## Docker Image for CodeIgniter4 development
[![Docker Build Status](https://img.shields.io/docker/cloud/build/atsanna/codeigniter4?style=for-the-badge)](https://hub.docker.com/r/atsanna/codeigniter4/)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/atsanna/codeigniter4/v4.1.1?style=for-the-badge)](https://hub.docker.com/r/atsanna/codeigniter4/)
![Docker Pulls](https://img.shields.io/docker/pulls/atsanna/codeigniter4?style=for-the-badge)

This repository provides you a development environment without requiring you to install PHP, a web server, and any other server software on your local machine. For this, it requires Docker and Docker Compose.

Basic example to create your container (tested on Ubuntu 18.04 - Docker version 19.03.5, build 633a0ea838):

**NOTE: This package is under early development and is not ready for prime-time.**

## Build Image

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
docker build . -t codeigniter:4.1.1
```

start the container:
```
docker container run --publish 80:80 --name ci4 -v /localfolder:/var/www/html codeigniter:4.1.1
```

## Installation

1. Install [docker](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/) ;

2. Copy `docker-compose.yml` file to your project root path, and edit it according to your needs ;

3. From your project directory, start up your application by running:

```sh
docker-compose up -d
```

4. From your project directory, stop your application by running:

```sh
docker-compose down --volumes
```

## Contributing

Contributions are welcome!
Leave an issue on Github, or create a Pull Request.


## Licence

This work is under [MIT](LICENSE) licence.
