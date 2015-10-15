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
* Tomcat7: http://192.168.33.20:9080 (För att köra WebGoat)

## Tips till laborationerna

### WebGoat
* Git-repo: git@ci:WebGoat-Legacy.git
* Bygga: mvn clean package

### Deploy till TEST
* Fixa SSH från jenkins@ci -> root@test (lägg till ~jenkins/.ssh/id-rsa.pub i slutet av /root/.ssh/authorized_keys)
* Kopiera WebGoat-6.0.1.war i /var/lib/tomcat7/webapps/webgoat.war mha. scp
* Starta om Tomcat på test: ssh root@test service tomcat7 restart
* Kolla att WebGoat kommer upp: wget -O /dev/null --retry-connrefused --tries 5 http://192.168.33.20:9080/webgoat

### Findbugs
* FindBugs och FindSecurityBugs: https://github.com/h3xstream/find-sec-bugs/wiki/Maven-configuration

### ZAP
* API-dokumentation: https://github.com/zaproxy/zaproxy/wiki/ApiPython
* För att installera lokalt: https://github.com/zaproxy/zaproxy/wiki/Downloads

### ThreadFix
* API-dokumentation: https://github.com/denimgroup/threadfix/wiki/Threadfix-REST-Interface
```
# Lista applikationer
$ curl -H 'Accept: application/json'  http://ci:9080/threadfix/rest/teams?apiKey=EmMnywKGQaq3aXnsefIyQvwfvTppnYEccOkVrcc88 | jq .

# Ladda upp en scanning
$ curl --insecure -H 'Accept: application/json' -X POST --form file=@target/findbugsXml.xml http://ci:9080/threadfix/rest/applications/2/upload?apiKey=EmMnywKGQaq3aXnsefIyQvwfvTppnYEccOkVrcc88
```

