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

# Needed for phantomjs to work
sudo apt-get install -y libfontconfig

#install node stuff
sudo apt-get install -y nodejs npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install grunt-cli -g
sudo npm install bower -g

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
sudo -i -u git git clone --mirror https://github.com/jakobkylberg/ci-frontendApp.git
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

sudo -i -u jenkins mkdir /var/lib/jenkins/jobs/FrontendApp_CommitStage
sudo -i -u jenkins cp /vagrant/FrontendApp_CommitStage.xml /var/lib/jenkins/jobs/FrontendApp_CommitStage
sudo -i -u jenkins mv /var/lib/jenkins/jobs/FrontendApp_CommitStage/FrontendApp_CommitStage.xml /var/lib/jenkins/jobs/FrontendApp_CommitStage/config.xml

# Copy settings.xml to .m2 dir
sudo -i -u jenkins mkdir /var/lib/jenkins/.m2
sudo cp /vagrant/settings.xml /var/lib/jenkins/.m2/
sudo chown jenkins:jenkins /var/lib/jenkins/.m2/settings.xml

# Install sonar qube
pushd ~
curl -OL http://dist.sonar.codehaus.org/sonarqube-5.0.1.zip
sudo unzip sonarqube-5.0.1.zip -d /etc
sudo ln -s /etc/sonarqube-5.0.1 /etc/sonarqube
printf "\nsonar.web.port=8083" | sudo tee -a  /etc/sonarqube/conf/sonar.properties
sudo ln -s /etc/sonarqube/bin/linux-x86-64/sonar.sh /usr/bin/sonar
sudo cp /vagrant/sonar /etc/init.d/
sudo chmod 755 /etc/init.d/sonar
sudo update-rc.d sonar defaults
sudo service sonar start
rm sonarqube-5.0.1.zip
popd

# Install Jenkins plugins
pushd /var/lib/jenkins/plugins
sudo curl -LO http://updates.jenkins-ci.org/latest/scm-api.hpi
sudo chown jenkins:jenkins scm-api.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/git-client.hpi
sudo chown jenkins:jenkins git-client.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/git.hpi
sudo chown jenkins:jenkins git.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/nodejs.hpi
sudo chown jenkins:jenkins nodejs.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/build-pipeline-plugin.hpi
sudo chown jenkins:jenkins build-pipeline-plugin.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/jquery.hpi
sudo chown jenkins:jenkins jquery.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/promoted-builds.hpi
sudo chown jenkins:jenkins promoted-builds.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/parameterized-trigger.hpi
sudo chown jenkins:jenkins parameterized-trigger.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/copyartifact.hpi
sudo chown jenkins:jenkins copyartifact.hpi
sudo curl -LO http://updates.jenkins-ci.org/latest/job-dsl.hpi
sudo chown jenkins:jenkins job-dsl.hpi
popd

# Start up Jenkins
sudo service jenkins start

#set up default jobs
sudo -i -u jenkins mkdir /var/lib/jenkins/jobs/BackendApp_CommitStage
sudo -i -u jenkins cp /vagrant/BackendApp_CommitStage.xml /var/lib/jenkins/jobs/BackendApp_CommitStage
sudo -i -u jenkins mv /var/lib/jenkins/jobs/BackendApp_CommitStage/BackendApp_CommitStage.xml /var/lib/jenkins/jobs/BackendApp_CommitStage/config.xml

sudo -i -u jenkins mkdir /var/lib/jenkins/jobs/FrontendApp_CommitStage
sudo -i -u jenkins cp /vagrant/FrontendApp_CommitStage.xml /var/lib/jenkins/jobs/FrontendApp_CommitStage
sudo -i -u jenkins mv /var/lib/jenkins/jobs/FrontendApp_CommitStage/FrontendApp_CommitStage.xml /var/lib/jenkins/jobs/FrontendApp_CommitStage/config.xml

sudo service jenkins restart

# Set environment variables
sudo cp /vagrant/environment /etc/environment

# Add addresses for puppet
sudo cat /vagrant/hosts >> /etc/hosts

# Setup puppet
cd ~; wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get -y -q install puppetmaster-passenger
sudo service apache2 stop
sudo touch /etc/puppet/manifests/site.pp

#hiera
sudo cp /vagrant/puppet/hiera/hiera.yaml /etc/
sudo mkdir /etc/puppet/hieradata
sudo cp /vagrant/puppet/hiera/test.yaml /etc/puppet/hieradata
sudo cp /vagrant/puppet/hiera/prod.yaml /etc/puppet/hieradata
sudo cp /vagrant/puppet/hiera/common.yaml /etc/puppet/hieradata

sudo cp /vagrant/puppet/master/puppet.conf /etc/puppet/puppet.conf
sudo rm -rf /var/lib/puppet/ssl
sudo cp /vagrant/puppet/master/puppetmaster.conf /etc/apache2/sites-enabled/puppetmaster.conf
# Install the puppet-nexus plugin
sudo mkdir /usr/share/puppet/modules
cd /etc/puppet/modules
sudo git clone https://github.com/cescoffier/puppet-nexus.git nexus
