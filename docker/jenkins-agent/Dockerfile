FROM jenkinsci/jnlp-slave:latest

COPY wait-for-it.sh wait-for-it.sh

ENTRYPOINT ["./wait-for-it.sh", "-t", "60", "--strict", "jenkins-master:50000"]
CMD ["--", "jenkins-slave"]
