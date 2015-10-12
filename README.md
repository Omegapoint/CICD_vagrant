#AppSäk i din CI/CD-setup

Omegapoint Academy Day Training

##Förberedelser

1. Följ instruktionerna under "Förberedelser" på https://github.com/Omegapoint/CICD_vagrant/blob/master/README.md
2. Byt branch till "appsec" och uppdatera CI- och TEST-maskinerna:

```
$ git checkout appsec
$ git pull
$ vagrant provision ci test
```

## Miljö

### CI: 192.168.33.10
* Jenkins: http://192.168.33.10:8080
* ThreadFix: http://192.168.33.10:9080/threadfix/login.jsp
* ZAP: http://127.0.0.1:12345 (från CI-maskinen)

### TEST: 192.168.33.20
* Tomcat7: http://192.168.33.20:9080 (För att köra Bodgeit Store)
