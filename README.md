# codeigniter4-docker
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
docker container run --publish 80:80 --name ci4 -v /app/test/localfolder:/var/www/html codeginiter:4.0.2
```
