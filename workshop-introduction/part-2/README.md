# Introduction to CI/CD - Part 2

## Goal

Create a Jenkins pipeline that will trigger when changes are pushed to the example application's git repository.

### 1. Pipelines as code

The traditional way of configuring a CI server or most infrastructure has been to configure it manually, either through a graphical user interface or through
  the command line. There are a lot disadvantages with this way of working and we will define our pipelines as code and not through the Jenkins' GUI.
   
### 2. Create a hello world pipeline

The first step is to create a hello world pipeline that will just print hello world and be done. In the Jenkins' GUI, click `New Item`, give your pipeline a name
 and select `Multibranch Pipeline` as the type. 

For Jenkins to be able to access the git-server it needs a key. That key is already provided as a credential in Jenkins'
 credentials store with the id `jenkins-ssh`.

Click `add source -> git`. Select the git credentials and enter the url to the git server in `Project Repository` field. 
 
Jenkins can access the git repository using the hostname `git-server` and port 22. The url for git repo from the point of view of Jenkins is apart from that the same as the one you used locally. 

Please note the heading `Build Configuration` and the configuration underneath. This means that his Jenkins job will look for a 
`Jenkinsfile` in the root of the repository of the example application and the code in the Jenkinsfile will be executed by the job.

This means that we'll have infrastructure as code under version control.

Click save to save the job configuration.

### 3. Write a hello world pipeline

Jenkins pipelines are written using Groovy. The pipeline script is then run by Jenkins in a sandbox with some limitations, for among 
 other things security reasons, which means that most but not all Groovy syntax is available. 
 
Create a `Jenkinsfile` in your local example application git repository and enter your pipeline code there.
 
There's a quite helpful snippet generator under `Pipeline Syntax` on the left side in Jenkins when you have opened your job.
 
Either use the snippet generator or write a pipeline stage that will print "Hello world". 

Commit and push your pipeline to the git repository.

When you've created a hello world pipeline, verify that it will output hello world and that the build is successful.

### 4. Trigger the build on changes in the git repository

The job should be triggered automatically when changes are pushed to the git repository. Jenkins can either poll the repository for
 changes or the git server can alert Jenkins on new changes by using a hook.
 
To simplify things we'll poll.

The easiest way to this is to configure the multibranch pipeline to poll, or using the language of the multibranch pipeline plugin, scan periodically if not otherwise run.

Push changes to the git repository and verify that a job is triggered.

### Documentation

[Jenkins pipeline documentation](https://jenkins.io/doc/pipeline/tour/getting-started/)
