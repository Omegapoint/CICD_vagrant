#
# docker build -t setup_image .
#
# docker run --rm -v docker_gitdata:/gitdata setup_image clone --bare https://github.com/Omegapoint/cicd-workshop-backend.git
#

FROM alpine

RUN apk --update add git openssh && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

WORKDIR /gitdata

ENTRYPOINT ["git"]
CMD ["--help"]