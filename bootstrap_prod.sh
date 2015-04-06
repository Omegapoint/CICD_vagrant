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
