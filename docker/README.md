# Docker setup

This directory contains a Docker and docker-compose configuration for the basic infrastructure
for the CICD Workshop. It sets up a Jenkins master instance with a default configuration, a few 
simple build agents, and a plain Git server.

## How to run

### Prerequisites

* [Docker CE][1]
* [docker-compose][2]
* [Java][3]
* [Maven][4] 

### Start Jenkins and the other servers

Begin by starting the project:

``` bash
$ docker-compose up -d
```

To access the Jenkins instance, open a browser and go to:
 
    http://localhost:80/

The default login credentials are:
 
    jenkins:jenkins

### Add you public key to the Git server

To be able to fetch from and push to the Git server, you will need to add your public key. If you do not already 
have an RSA keypair you need to generate one before doing this:

```bash
$ ssh-keygen -t rsa
```

To add your public key to the Git server, copy it into the `git` users authorized keys file:

```bash
$ docker-compose exec git-server sh -c "echo '$(cat ~/.ssh/id_rsa.pub)' >> /etc/authorized_keys/git"
```

To verify that you have access you should be able to run the following command and see the same output:

```bash
$ ssh git@localhost -p 2222
Welcome to the CI/CD workshop Git server!
=== Congratulations! ===
You've successfully authenticated, but I do not provide interactive shell access.
Connection to localhost closed.
```

#### Clone the workshop projects from the Git server

You can now clone the project that you will be working on for this workshop:

```bash
$ git clone ssh://git@localhost:2222/repos/cicd-workshop-backend
```

### Add your public key to the prod and test servers

For this workshop we have included two containers that represent production and test server respectively.
To access these you need to add your public key to the `docker` users authorized keys:

```bash
$ docker-compose exec test-server sh -c "echo '$(cat ~/.ssh/id_rsa.pub)' >> /etc/authorized_keys/docker"
```

(Note that you only have to do it for either `test-server` or `prod-server` as they both share the same folder for authorized keys.)

To verify that you have access and can run Docker on the prod and test server, you should be able to do the following:

```bash
$ ssh docker@localhost -p 2223

[...]

Welcome to the CI/CD workshop test server!
$ sudo docker run hello-world

[...]

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```

[1]: https://docs.docker.com/engine/installation/
[2]: https://docs.docker.com/compose/install/
