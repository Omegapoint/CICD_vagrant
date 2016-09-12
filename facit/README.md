# CI/CD Lab - Building your own pipeline
##### Team Multicore
<[StockholmConsultingMulticore@omegapoint.se](mailto:StockholmConsultingMulticore@omegapoint.se)>  
*version 1.0, 2016-02*

This is the main documentation for teachers holding the labs CI/CD course at Omegapoint. The lab consists of two parts, day1 and day2. 
Day 1 focuses on building an initial pipeline which includes automatic testing and deployment of the application.
This documentation mainly consists of cheat sheets and alternative ways of performing an operation.

## Overview
The lab has three virtual machines, provisioned using vagrant. The application consists of separated backend and frontend applications, each with unit tests.

### Virtual machines
There are three virtual machines that should be run in parallel

#### CI/CD machine
| Info         | Value                            |
|:-------------|:---------------------------------|
| OS           | Ubuntu 14.04.1 LTS (Trusty Tahr) |
| IP           | 192.168.33.10                    |
| Vagrant name | ci                               |
| Memory       | 2gb                              |
| Java         | Oracle JDK 8                     |


###### Jenkins
```sh
http://192.168.33.10:8080
```

###### Nexus
```sh
http://192.168.33.10:8081/nexus
user: admin
password: admin123
```

###### SonarQube
```sh
http://192.168.33.10:8083
user: admin password: admin
```

###### SSH Access
```sh
vagrant ssh ci
```

#### Test machine
| Info             | Value                            |
|:-----------------|:---------------------------------|
| OS               | Ubuntu 14.04.1 LTS (Trusty Tahr) |
| IP               | 192.168.33.20                    |
| Vagrant name     | test                             |
| Memory           | 512mb                            |
| Java             | Oracle JDK 8                     |
| Apache Webserver |                                  |
| Jetty 8          | /usr/share/jetty8                |


###### SSH Access
```sh
vagrant ssh test
```

#### Prod machine
| Info             | Value                            |
|:-----------------|:---------------------------------|
| OS               | Ubuntu 14.04.1 LTS (Trusty Tahr) |
| IP               | 192.168.33.20                    |
| Vagrant name     | prod                             |
| Memory           | 512mb                            |
| Java             | Oracle JDK 8                     |
| Apache Webserver |                                  |
| Jetty 8          | /usr/share/jetty8                |


###### SSH Access
```sh
vagrant ssh prod
```

### Application

#### Backend
The backend application is written in Java and uses Spring Boot. The applications also have some unit tests which can be run in the pipeline.
The backend has only one endpoint:

```sh
"/Persons.json"
```

>The application has a filter (CORSFilter.java) which allows cross origin request, enabling the frontend application be completely standalone. Without this, both backend and frontend would have to be connected and always deployed at the same time.


###### Git repository
```sh
git@192.168.33.10:cicd-workshop-backend.git
```

###### Build
```sh
mvn clean package
```

> Packaging the backend project will create an tar.gz containing the backend jar + an shell script for simplifying start/stop of the server. The jar itself is also available in the target catalog, which can be picked up by Jenkins archive plugins.

###### Unpack to catalog
```sh
tar xzvf target/cicd-lab-backend-1.0-bin.tar.gz -C ~
```

###### Start application
```sh
cd ~/cicd-lab-backend-1.0 && ./application.sh start
```

###### application.sh has the ability to start, stop and show status for the application
```sh
application.sh [start|stop|restart|debug|status]
```

###### The test and prod virtual machine has a init.d scription which can start and stop the backend service
```sh
service cicd-lab-backend.sh [start|stop]
```
###### This simplifies the update process, as only the jar needs to be fetched from Nexus.
> In order for the service script to work, the script cicd-lab-backend.sh must be available in /etc/init.d/ If not present, check if existing in /vagrant/ and move to /etc/init.d (see bootstrap_test/prod.sh)

#### Frontend
The frontend application is written in Javascript with AngularJS. The application is build using Node/Grunt and tested using Karma/Jasmine As the frontend consists only of static content, it can be served using an Apache web server which is installed on both the test and prod virtual machine.  

The application runs against a backend specified in config/settings.json. This file is different for each environment.
You can immediately test that the Apache server is serving content at
```sh
http://192.168.33.20
```

###### Git repository:
```sh
git@192.168.33.10:cicd-workshop-frontend.git
```


#### Setup
```sh
npm install -g grunt-cli
npm install -g bower
npm install
bower install
```

###### Run application
```sh
grunt serve
```
###### Run tests
```sh
grunt test
```

###### Build application (minimize etc.)
```sh
grunt build
```

###### Specifying backend
Create or update settings.json with the following content:
```json
{ "REST_ENDPOINT": "http://192.168.33.20:8080" }
```
The file should be put at /var/www/html/mc-angular/config/settings.json in the test or prod environment.

## Day 1
The main goal with this lab is to create two working build pipelines, one for backend and one for frontend. Both applications are available in git-repositories inside the CI machine. The pipelines are responsible for building, testing and deploying the application to the test environment automatically.

* The pipelines should trigger each job downstream automatically after successful builds.
* Mail should be sent to the user responsible for making a build fail, e.g. failing tests.
* An easy way to visualize the pipeline is to use Jenkins Build Pipeline plugin or Delivery Pipeline plugin.
* A final, manually triggered, step is to deploy a build to the production environment

### Overview
Three jobs are suggested:
* **test_[frontend/backend]**: Responsible for detecting changes in Git, fetching changes and running tests. Successful tests also packages the application
* **publish_[frontend/backend]_snapshot_to_nexus**: Middle step where all successful build packages are stored.
* **deploy_[frontend/backend]to_[test/prod]**: Deploys an artifact to test/prod environment

> Do not use spaces in the job name. While Jenkins can handle it graphically, the underlying folder structure might not be optimal depending on operating system running Jenkins. There are other settings, such Display name etc. if pretty job names are wanted

An example of a pipeline is shown below using the Delivery Pipeline plugin

![Frontend Pipeline][frontend-pipeline img]


### Backend
Jenkins is available at http://192.168.33.10:8080

#### Test job
1. Create new **Maven project** job in Jenkins, name it test_backend or similiar
2. Source code management, enter git repo: **git@192.168.33.10:cicd-lab-backend.git**
3. Build triggers, check **Poll SCM** and enter '* * * * *' without quotes. This will make Jenkins check the repo every minute for changes
4. Build, Add **clean install -Dversion=1.0.${BUILD_NUMBER}** to Goals and options
5. Build settings check **Email notification** and check only option **Send separate e-mails to individuals who broke the build**
6. Post build **Archive artifacts target/cicd-lab-backend-*****.jar**
7. Post build, publish Junit result, files: target/surefire-reports/**. Can be found by looking in 'workspace' on jenkins
8. (Trigger next with predefined **BuildId=${BUILD_NUMBER}**)

#### Publish job
1. Create new **Freestyle** job in Jenkins, name it **publish_backend** or similiar
2. Check **This build is parameterized**
3. Add parameter **String parameter**. Set name to **BuildId**
4. Add parameter **Build selector for Copy Artifact**. Set name to **BuildVal**. Specific Build **${BuildId}**
5. Add build step **Copy artifact** Which build: Specific: **${BuildVal}**
6. Build, Add shell step with the following:
```sh
mvn deploy:deploy-file \
-DgroupId=se.omegapoint \
-DartifactId=cicd-lab-backend \
-Dversion=1.0.${BuildId} \
-Dpackaging=jar \
-Dfile=target/cicd-lab-backend-1.0.${BuildId}.jar \
-DrepositoryId=deployment \
-Durl=http://192.168.33.10:8081/nexus/content/repositories/releases \
--settings=/var/lib/jenkins/.m2/settings.xml
```

#### Deploy job
1. Create new **Freestyle** job in Jenkins, name it **deploy_backend** or similiar
2. Check **This build is parameterized**
3. Add parameter **String** parameter. Set name to **BuildId**
4. Build, Add **shell step**
```sh
ssh 192.168.33.20 "service cicd-lab-backend.sh stop"
sleep 1
wget --content-disposition -q -O /tmp/cicd-lab-backend-1.0.${BuildId}.jar "http://192.168.33.10:8081/nexus/service/local/artifact/maven/redirect?r=releases&g=se.omegapoint&a=cicd-lab-backend&v=1.0.${BuildId}&e=jar"
rsync /tmp/cicd-lab-backend-1.0.${BuildId}.jar 192.168.33.20:/opt/cicd-lab-backend/
ssh 192.168.33.20 "(cd /opt/cicd-lab-backend; service cicd-lab-backend.sh start)"
```

## Copyright Omegapoint 2016

[frontend-pipeline img]:frontend-pipeline.png