FROM jenkins/jenkins:lts

USER root
RUN apt-get update \
      && apt-get install -y sudo \
&& rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
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
RUN mkdir /usr/docker-bin
RUN echo '#!/bin/sh' >> /usr/docker-bin/docker
RUN echo 'sudo docker "$@"' >> /usr/docker-bin/docker
RUN chmod a+rx /usr/docker-bin/docker
ENV PATH /usr/docker-bin:$PATH
USER jenkins
