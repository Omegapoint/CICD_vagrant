#!/usr/bin/env bash
#
# This scripts extracts Jenkins configuration from the currently running Docker container.
# The files to include are specified in config-files-to-copy.txt and the copied configuration
# is saved in a file call jenkins-config.tar.gz in the current folder.
#

docker cp config-files-to-copy.txt docker_jenkins-master_1:/tmp/config-files-to-copy.txt
docker exec docker_jenkins-master_1 bash -c "tar -czvf /tmp/jenkins-config.tar.gz -C /var/jenkins_home -T /tmp/config-files-to-copy.txt"
docker cp docker_jenkins-master_1:/tmp/jenkins-config.tar.gz jenkins-config.tar.gz
