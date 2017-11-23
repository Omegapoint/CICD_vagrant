# Docker setup

This directory contains a Docker and docker-compose configuration for the basic infrastructure
for the CICD Workshop. It sets up a Jenkins master instance with a default configuration, a few 
simple build agents, and a plain Git server.

## How to run

### Prerequisites

* [Docker CE][1]
* [docker-compose][2]

### Start Jenkins and Git server

``` bash
$ docker-compose up -d
```

To access the Jenkins instance, open a browser and go to http://localhost:80/

The default login credentials are jenkins:jenkins.

### Clone the project

You can clone the cicd-workshop-backend project from the Git server:

```bash
$ git clone ssh://git@localhost:2222/git-server/repos/cicd-workshop-backend.git
```

[1]: https://docs.docker.com/engine/installation/
[2]: https://docs.docker.com/compose/install/
