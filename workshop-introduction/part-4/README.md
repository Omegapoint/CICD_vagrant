# Introduction to CI/CD - Part 4

## Goal

The goal of the final part of the workshop is to have to different pipelines: one that will run continuous integration 
on all branches except the master branch. The master branch will be treated differently and will deploy everything that 
is pushed to the master branch.

### 1. Separate the pipelines

If the general SCM checkout is being used, the branch name is provided as a variable that can be used
 to branch the pipeline code. (See the provided `Jenkinsfile` in this folder if you get stuck)
 
Update the pipeline code so that there are a two separate paths (e.g. using a simple if-else statement) depending on
 if it's the master branch or any other branch that is being built.
 
At this point both the master pipeline and the pipeline for any other branch can do the same thing, run the test suite
 using maven.
 
### 2. Build a docker image for the example application

The pipeline for the master branch is going to deploy to the example application eventually. As we want to run the 
example application as a docker container we need to build a docker image of the application. Essentially we want to
do the same thing we did in part 1 where we built a docker image locally, but this time in the pipeline.

To recap: build the application's fat jar using maven and then build the image using docker build. Jenkins' docker plugin
can build images.

Implement this in a stage in the master pipeline. 
 
The image when built will be stored locally on your laptop by docker. In a real setup a private registry would be used 
 instead where images can be stored and shared.
 
Verify that you've succeeded by running `docker image ls` on your laptop. You should see the image that your pipeline built.

## The deployment Pipeline

At this point there a three steps left for the pipeline: deploy the example application to the test environment, verify 
the application in the test environment and finally if the verification in the test environment passes, deploy the 
example application to the production environment. 

As you might remember from the setup instructions in the beginning, there are two Docker containers called test-server
 and prod-server that simulates a test server and production server respectively. They will be used in the last part of
 the workshop.

### 3. Deploy and run the docker image

The next step is to deploy the example in the test environment using the test server. To deploy using the test server,
 ssh to the test server and execute docker run to start a docker container that will be test environment instance of
 the example application. As all docker containers in the end run on the same local docker engine we have to make sure 
 that we assign and expose different ports to all our containers.
 
To execute a command using ssh on another host (e.g. the test-server): `ssh -t <username>@<host> <command>`.

To run the example application use `docker run`. Useful options to the `docker run` command are the publish port, 
the detached, and the name option. The publish port option will enable you to assign a port to the container which is 
 essential. The name option will give the running container a name which is helpful, e.g. if you want to distinguish 
 between the test environment example app and the production environment example app. Finally, the detached option will
 run the docker container in the background.

Verify that you can reach the deployed example application on the assigned port.

### 4. Test and deploy to production

The final part of the pipeline should verify that the example application is working in the test environment. If so, it
 should be deployed to the production environment. 
 
Proper automated testing is a course in itself, so to simplify things we'll just do a simple test using e.g. `curl` to 
verify that the example application in the test environment is working properly. 

Docker has the concept of networks, and if you start the example application on the same network as Jenkins is running
 on, you can access the example application's container on a host name that is the same as the name you gave the 
 example application container when you started it. 
 
To list the available docker networks run `docker network ls`, to inspect a network to see which containers are on a 
 specific network, run `docker network inspect <network>`. The docker run command in the the previous step can be amended
 to let the container start in a specific network.

If the test environment verification step passes, the example application should be deployed to the production 
environment.

The deployment to the production environment can be done in the same manner as to the test environment.

Test the pipeline by first releasing a working build to production and then verifying that a faulty build will be stopped
 by the verification in the test environment.

Voilà! You have built a fully working CI/CD pipeline!

### Documentation

[Docker Pipeline Plugin](https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/index.html#docker-workflow)
