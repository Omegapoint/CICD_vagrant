# Omegapoint CI/CD vagrant
Virtuella maskiner för Omegapoint ABs CI/CD-kompetensdagar.

## Vagrant
 - Gå till https://www.vagrantup.com/ och ladda ner respektive installationspaket för din dator.
 - Installera paketet och starta om datorn
 - Använd Git för att klona detta projekt från github
 - Kör 'vagrant up' i projektkatalogen
 - Vänta! Det kommer att ta en stund!
 
## CI/CD maskin
### Allmänt:
 - OS: Ubuntu 14.04.1 LTS (Trusty Tahr) 
 - IP: 192.168.33.10
 - Minne: 2 GB
 - Java: OpenJDK 7, Oracle JDK 7, Oracle JDK 8
 
### Jenkins:
 http://192.168.33.10:8080/

### Nexus:
 http://192.168.33.10:8081/nexus
 
 user: admin
 password: admin123
 
### Artifactory:
 http://192.168.33.10:8082/artifactory
 
 user: admin
 password: password

### Git:
På din host-dator:
 - ssh-add keys/id_rsa

 - git clone git@192.168.33.10:cicd-lab-backend.git
 - git clone git@192.168.33.10:ci-frontendApp.git

## TEST maskin
### Allmänt:
 - OS: Ubuntu 14.04.1 LTS (Trusty Tahr) 
 - IP: 192.168.33.20
 - Minne: 512 MB
 - Java: OpenJDK 7, Oracle JDK 7, Oracle JDK 8
 - Jetty 8 (/usr/share/jetty8)
 
## PROD maskin
### Allmänt:
 - OS: Ubuntu 14.04.1 LTS (Trusty Tahr) 
 - IP: 192.168.33.30
 - Minne: 512 MB
 - Java: OpenJDK 7, Oracle JDK 7, Oracle JDK 8
 - Jetty 8 (/usr/share/jetty8)