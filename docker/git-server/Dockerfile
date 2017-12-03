FROM jkarlos/git-server-docker

WORKDIR /git-server/repos
RUN git clone --bare https://github.com/Omegapoint/cicd-workshop-backend.git cicd-workshop-backend.git

# Set workdir to /git-server/ because the command in jkarlos/git-server-docker assumes it is there to run start.sh
WORKDIR /git-server/
