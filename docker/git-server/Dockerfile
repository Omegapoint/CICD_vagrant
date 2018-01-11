FROM docker.io/panubo/sshd

# Create git user here as well even though it is also be specified in SSH_USERS because
# we want to use a custom shell and want it to own the git-shell-commands and the
# /repos folder
RUN adduser -D -s /usr/bin/git-shell git

RUN mkdir /repos && chown -R git:git /repos

# This is a login shell for SSH accounts to provide restricted Git access.
# It permits execution only of server-side Git commands implementing the
# pull/push functionality, plus custom commands present in a subdirectory
# named git-shell-commands in the user’s home directory.
# More info: https://git-scm.com/docs/git-shell
COPY git-shell-commands /home/git/git-shell-commands

RUN find /home/git -exec chown -R git:git {} \;
RUN find /home/git/git-shell-commands -type f -exec chmod u+x {} \;

USER git

# Clone the repositories we need

RUN cd /repos \
    && git clone --bare https://github.com/Omegapoint/cicd-workshop-backend.git cicd-workshop-backend.git

USER root
