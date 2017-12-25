FROM docker.io/panubo/sshd

# Install Docker

RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini docker

# Setup sudo for "docker" user to be able to run Docker commands
RUN apk add --no-cache sudo
RUN echo "docker ALL=NOPASSWD: ALL" >> /etc/sudoers
