# Docker setup
Describes how to create and run the docker containers that will simulate your 
development/testing/production environment

## Setup
Start by creating keys and docker volumes. These are needed so specific data is persistent when 
containers are restarted/recreated. 

[Setup volume/kyes](setup/README.md)

## Create images

Build the images, example:

    $ docker-compose build    
    
Run the images:

    $ docker-compose up
    
Follow the instructions in http://localhost/ to set up jenkins

Create a new Pipeline-job and insert some docker code, as an example, use this [Jenkinsfile](Jenkinsfile)

Clone repository:

    $ git clone ssh://git@localhost:2222/git-server/repos/cicd-workshop-backend.git
    
    
For backup purposes, mount the docker_jenkinsdata volume:
docker run --rm -it --mount source=docker_jenkinsdata,target=/var/jenkins_home ubuntu bash
