FROM jenkins/jenkins:lts

ARG docker_gid
USER root
RUN groupadd docker --gid=$docker_gid
COPY docker-engine.key /tmp/docker-engine.key
RUN mkdir /var/log/jenkins
RUN mkdir /var/cache/jenkins
RUN chown -R jenkins:jenkins /var/jenkins_home
RUN chown -R jenkins:jenkins /var/log/jenkins
RUN chown -R jenkins:jenkins /var/cache/jenkins
RUN chmod a+rw /var/jenkins_home
RUN ls -la /var/jenkins_home
RUN apt-get update && echo "deb https://apt.dockerproject.org/repo debian-stretch main" > /etc/apt/sources.list.d/docker.list \
&& apt-get install apt-transport-https && apt-key add /tmp/docker-engine.key && apt-get update && apt-get install -y docker-engine
RUN usermod -aG docker jenkins
#RUN ssh-keygen -f /tmp/key
#RUN chmod a+rw /tmp/*
#USER jenkins
