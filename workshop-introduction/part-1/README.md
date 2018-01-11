# Introduction to CI/CD - Part 1

## Goal

1. Familiarize yourself with the example application that is going to be used throughout the workshop.
2. Build and run the application as a fat jar.
3. Build and run the application as a docker container.

### 1. Clone the Example Application

Clone the example application repository from the git-server that you just set up during the preparations.

```bash
$ git clone ssh://git@localhost:2222/repos/cicd-workshop-backend
```
### 2. Open the Example Application In Your IDE

Open the example application in your IDE. Familiarize yourself with the code, look at the tests, the endpoint and run it from the IDE.

### 3. Run tests from the command line

Run the tests from the command line using Maven.

### 4. Build a fat jar

Using the maven package lifecycle phase, you can build a fat jar containing the application and all its dependencies. This means that  all you need to run the application is the fat jar and the Java Runtime Environment.
 
When you've build the fat jar using maven, run the fat jar using Java from the command line and verify that it works.

### 6. Build docker image locally

The next step is to build a Docker image with the Java Runtime Environment and your fat jar. In the root of the repository of the example application there's
 a `Dockerfile`. The Dockerfile specifies how the docker image should be built. Have a look at how the Dockerfile is written and then try to build a Docker image
 using the provided Dockerfile with the [`docker run`](https://docs.docker.com/engine/reference/commandline/build/) command.

### 7. Run docker image locally

When the docker image has been successfully built and placed in your local Docker registry, it's available to be run as a Docker container. Run the application as a 
Docker container using [`docker run`](https://docs.docker.com/engine/reference/commandline/run/) and verify that it works.

Now you have learnt how to build a Docker image for your application. Running your applications as Docker containers is a great way realize not only continuous delivery but a
 microservice architecture as well. 
