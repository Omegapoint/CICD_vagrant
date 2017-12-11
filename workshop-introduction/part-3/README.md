# Introduction to CI/CD - Part 3

## Goal

The goal is to on every push to the git server trigger a build that will run the example applications test suite.

### 1. Run the tests in a Docker container

We want to avoid sharing state for the different jobs that the Jenkins server runs. E.g. we want
 to avoid to have a common maven repository on the Jenkins server.
 
We want to avoid configuring the Jenkins server for the needs of different jobs as well. Different jobs can at times 
have conflicting configuration requirements.

The solution is to do the work of our pipelines in docker containers. In our case we want to run
 our test suite in a docker container with maven.

#### 1.1 Find a suitable docker image

Find a suitable docker image with maven preinstalled.

#### 1.2 Update your pipeline to run a maven command in a docker container

Update your pipeline to run a basic maven command in the maven docker container, e.g. 
 `mvn --version` to verify that everything works as expected.

#### 1.3 Update your pipeline to run the test suite

Update the pipeline to run the test suite using maven.

#### 1.4 Verify the pipeline

Add a failing test and verify that the pipeline fails. Remove the test and verify that the pipeline turns 
turns blue.

You now have a pipeline that automatically will test your code on a push to the git repository.

### Documentation

[Docker Pipeline Plugin](https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/index.html#docker-workflow)

