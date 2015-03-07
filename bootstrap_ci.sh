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
apt-get update
apt-get install -y apache2 maven jenkins git unzip


# Generate key pair to be used by git if they do not exist already
if [ ! -d /vagrant/keys ]; then
  mkdir -p /vagrant/keys
  pushd /vagrant/keys
  ssh-keygen -t rsa -C "omegapoint" -q -f id_rsa -N ''
  popd
fi

# Set up git server
sudo adduser --disabled-password --gecos "" git
cd /home/git
sudo -u git mkdir .ssh && sudo -u git chmod 700 .ssh
sudo -u git touch .ssh/authorized_keys && sudo -u git chmod 600 .ssh/authorized_keys
sudo -u git cat /vagrant/keys/id_rsa.pub >> ~/.ssh/authorized_keys
sudo -u git mkdir cicd_repo.git
cd cicd_repo.git
sudo -u git git init --bare


# Install Artifactory
pushd /opt
sudo wget -O artifactory-3.5.1.zip http://bit.ly/Hqv9aj
sudo unzip artifactory-3.5.1.zip
sudo rm -f artifactory-3.5.1.zip
sudo ln -s `ls -1d artifactory-*` artifactory
sudo artifactory-3.5.1/bin/installService.sh
sudo cp /vagrant/artifactory_server.xml /opt/artifactory/tomcat/conf/server.xml
sudo service artifactory start
popd


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

# Start up Jenkins
sudo service jenkins start



# Set environment variables
sudo cp /vagrant/environment /etc/environment