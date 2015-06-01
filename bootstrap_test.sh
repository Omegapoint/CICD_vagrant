#!/usr/bin/env bash

# Basic stuff
apt-get update
apt-get install -y git unzip

# Install Apache web server
sudo apt-get install -y apache2

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

# Install Jetty 8
apt-get install -y jetty8

# Enable Jetty8 by editing /etc/default/jetty8
sudo sed -i '/NO_START=1/c\NO_START=0' /etc/default/jetty8
sudo sed -i '/JAVA_HOME/c\JAVA_HOME=/usr/lib/jvm/java-8-oracle' /etc/default/jetty8

# Starting Jetty8
sudo update-rc.d jetty8 defaults
sudo service jetty8 stop

# Set environment variables
sudo cp /vagrant/environment_run /etc/environment

# Add init.d script for the cicd-lab-backend
sudo cp /vagrant/cicd-lab-backend.sh /etc/init.d/
sudo chmod 700 /etc/init.d/cicd-lab-backend.sh

# Setup puppet addresses
sudo cat /vagrant/hosts >> /etc/hosts

# Setup puppet
cd ~; wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get -y -q install puppet
sudo cp /vagrant/puppet/slave/puppet /etc/default/puppet
sudo cp /vagrant/puppet/slave/puppet.conf /etc/puppet/puppet.conf
# Install the puppet-nexus plugin
sudo mkdir /usr/share/puppet/modules
cd /usr/share/puppet/modules
sudo git clone https://github.com/cescoffier/puppet-nexus.git nexus
