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

### 3. Deploy and run the docker image

TODO

### 4. Test and deploy to production

TODO
 
### Documentation

[Docker Pipeline Plugin](https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/index.html#docker-workflow)
 
