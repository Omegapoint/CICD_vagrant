#!/usr/bin/env bash

# Add sources for jenkins to APT
sudo wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo echo "deb http://pkg.jenkins-ci.org/debian binary/" >> /etc/apt/sources.list


# Install Oracle Java 8
# (thanks to https://gist.github.com/tinkerware/cf0c47bb69bf42c2d740)
apt-get -y -q update
apt-get -y -q upgrade
apt-get -y -q install software-properties-common htop
add-apt-repository ppa:webupd8team/java
apt-get -y -q update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y -q install oracle-java8-installer
update-java-alternatives -s java-8-oracle


# Basic stuff
apt-get install -y apache2 maven jenkins git unzip


# Generate key pair to be used by git if they do not exist already
if [ ! -d /vagrant/keys ]; then
  mkdir -p /vagrant/keys
  pushd /vagrant/keys
  ssh-keygen -t rsa -C "git@192.168.33.10" -q -f id_rsa -N ''
  popd
fi

# Set up git server
sudo adduser --disabled-password --gecos "" git
pushd /home/git
sudo -i -u git git config --global user.name "vagrant"
sudo -i -u git git config --global user.email "vagrant@omegapoint.se"
sudo -i -u git mkdir .ssh
sudo -i -u git chmod 700 .ssh
sudo -i -u git touch .ssh/authorized_keys
sudo -i -u git chmod 600 .ssh/authorized_keys
sudo -i -u git cat /vagrant/keys/id_rsa.pub > .ssh/authorized_keys

# Make an empty git repository
#sudo -u git mkdir cicd_repo.git
#cd cicd_repo.git
#sudo -u git git init --bare

# Clone the repositories for the frontend and backend application from github.com
sudo -i -u git git clone --mirror https://github.com/jakobkylberg/cicd-lab-backend.git
sudo -i -u git git clone --mirror https://github.com/thalen/ci-frontendApp.git
popd

## Install Artifactory
#pushd /opt
#sudo wget -O artifactory-3.5.1.zip http://bit.ly/Hqv9aj
#sudo unzip artifactory-3.5.1.zip
#sudo rm -f artifactory-3.5.1.zip
#sudo ln -s `ls -1d artifactory-*` artifactory
#sudo artifactory-3.5.1/bin/installService.sh
#sudo cp /vagrant/artifactory_server.xml /opt/artifactory/tomcat/conf/server.xml
#sudo service artifactory start
#popd


# Install Nexus
pushd /usr/local
sudo wget -q -O nexus-latest-bundle.tar.gz http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz
sudo tar xzf nexus-latest-bundle.tar.gz
sudo rm -f nexus-latest-bundle.tar.gz
sudo ln -s `ls -1d nexus-*` nexus
sudo cp /vagrant/nexus /etc/init.d/nexus
sudo chown root /etc/init.d/nexus
sudo chmod 755 /etc/init.d/nexus
pushd /etc/init.d
sudo update-rc.d nexus defaults
sudo service nexus start
popd
popd

# Copy keys before starting up jenkins
sudo -i -u jenkins mkdir /var/lib/jenkins/.ssh
sudo cp /vagrant/keys/id_rsa /var/lib/jenkins/.ssh/
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa
sudo -i -u jenkins cp /vagrant/keys/id_rsa.pub /var/lib/jenkins/.ssh/
sudo -i -u jenkins cp /vagrant/keys/known_hosts /var/lib/jenkins/.ssh/
sudo -i -u jenkins chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo -i -u jenkins ssh-keyscan -H 192.168.33.10 >> /var/lib/jenkins/.ssh/known_hosts

# Start up Jenkins
sudo service jenkins start

# Set environment variables
sudo cp /vagrant/environment /etc/environment