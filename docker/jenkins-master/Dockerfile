FROM jenkinsci/jenkins:2.89.2

#
# ROOT
#

USER root

# Prep Jenkins directories
RUN mkdir /var/log/jenkins
RUN mkdir /var/cache/jenkins
RUN chown -R jenkins:jenkins /var/log/jenkins
RUN chown -R jenkins:jenkins /var/cache/jenkins

# Setup sudo for "jenkins" user to be able to run Docker commands
RUN apt-get update \
      && apt-get install -y sudo \
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# Make docker wrapper around sudo docker, so that the jenkins-master container can run as 'jenkins' and run Docker along with Docker
RUN mkdir /usr/docker-bin
RUN echo '#!/bin/sh' >> /usr/docker-bin/docker
RUN echo 'sudo docker "$@"' >> /usr/docker-bin/docker
RUN chmod a+rx /usr/docker-bin/docker
ENV PATH /usr/docker-bin:$PATH

# Install Docker Engine (socket must be mounted from host machine)
RUN apt-get update \
      && apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg2 \
            software-properties-common \
      && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
      && add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/debian \
            $(lsb_release -cs) \
            stable" \
      && apt-get update \
      && apt-get install -y docker-ce

# Install Docker compose
RUN curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
      && chmod +x /usr/local/bin/docker-compose

#
# JENKINS
#

USER jenkins

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Add default configuration
COPY jenkins-config.tar.gz /tmp/jenkins-config.tar.gz
RUN tar -xvf /tmp/jenkins-config.tar.gz -C /usr/share/jenkins/ref

USER root
RUN rm /tmp/jenkins-config.tar.gz
USER jenkins

# Add public key to Git server
USER root
RUN mkdir -p /keys && cat /usr/share/jenkins/ref/.ssh/id_rsa.pub >> /keys/git
USER jenkins

# Set defaults
ENV JAVA_OPTS="-Xmx8192m -Duser.timezone=Europe/Stockholm -Djenkins.install.runSetupWizard=false"
ENV JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war"
