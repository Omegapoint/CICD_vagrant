# Docker setup

This directory contains a Docker and docker-compose configuration for the basic infrastructure
for the CICD Workshop. It sets up a Jenkins master instance with a default configuration, a few 
simple build agents, and a plain Git server.

## How to run

### Prerequisites

* [Docker CE][1]
* [docker-compose][2]

### Start Jenkins and Git server

Begin by starting the project:

``` bash
$ docker-compose up -d
```

To access the Jenkins instance, open a browser and go to:
 
    http://localhost:80/

The default login credentials are:
 
    jenkins:jenkins.

### Add you public key to the Git server

To be able to fetch from and push to the Git server, you will need to add your public key. If you do not already 
have an RSA keypair you need to generate one before doing this:

```bash
$ ssh-keygen -t rsa
```

To add your public key to the Git server:

```bash
# First copy the key into the Git server container
$ docker cp ~/.ssh/id_rsa.pub docker_git-server_1:/git-server/keys
# Then restart the container
$ docker-compose restart git-server
# And finally verify that you have access
$ ssh git@0.0.0.0 -p 2222
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <http://wiki.alpinelinux.org>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

Welcome to git-server-docker!
You've successfully authenticated, but I do not
provide interactive shell access.
Connection to 0.0.0.0 closed.
```

### Clone the project

You can clone the cicd-workshop-backend project from the Git server:

```bash
$ git clone ssh://git@localhost:2222/git-server/repos/cicd-workshop-backend.git
```

[1]: https://docs.docker.com/engine/installation/
[2]: https://docs.docker.com/compose/install/
