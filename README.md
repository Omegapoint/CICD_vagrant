#Kompetensdag CI/CD dag 2

##Förberedelser

1. Installera git och ssh
 - Windows: https://msysgit.github.io/ Välj förvalda alternativ
 - Mac OS: Använd ‘port’ (https://www.macports.org/), ‘fink’ (http://www.finkproject.org/) eller någon annan väg
2. Ladda ner och installera VirtualBox (https://www.virtualbox.org)
3. Gå till https://www.vagrantup.com/ och ladda ner respektive installationspaket för din dator.
4. Installera paketet och starta om datorn
5. Klona git-repot med vagrantkonfiguration och provisioneringsskript i lämplig katalog:

```$ git clone https://github.com/Omegapoint/CICD_vagrant.git```
```$ git checkout dag2```

5. Kör ```vagrant up``` i den klonade projektkatalogen. 
 - Om den definierade timeouttiden inte räcker till så kan utökas genom att lägga till config.vm.boot_timeout = 3000 (efter config.vm.box) i Vagrantfile. På Windows är det sannolikt är det dock inte ett timeoutproblem utan att Windows ibland har svårt att hantera virtuella 64-bitars system. Byt i så fall till config.vm.box = "ubuntu/trusty32" istf config.vm.box = "ubuntu/trusty64".
6. Vänta (kan ta upp emot 45 min)

##Förutsättningar

För denna labb finns två jenkinsjobb förberedda som du kan utgå ifrån, FrontendApp_CommitStage samt BackendApp_CommitStage
Dessa jobb checkar ut koden, kör igenom enhetstester och bygger.

##Uppgift 1

Första uppgiften är att efter att ett stabilt bygge exekverats så ska det vara möjligt att ladda upp artefakterna i nexus,
vi kommer sedan använda nexus för att göra installationer i test och prodmiljön.

För maven finns det inbyggt stöd för att ladda upp till nexus mha mvn:deploy. Vad du dock behöver göra är att lägga till en distributionManagement tag i din pom-fil.
Hur man gör det finns beskrivet här:
https://support.sonatype.com/entries/21283268-Configure-Maven-to-Deploy-to-Nexus

För frontendappen så använder vi inte maven, men nexus har ett rest API som vi kan använda, implementera deploy-steget genom att använda curl:
```curl -v -F "r=releases" -F "g=application" -F "a=applicationName" -F "v="x.y.z" -F "p=tar.gz" -F 
"file=@./kod/dist/file" -u admin:admin123 http://192.168.33.10:8081/nexus/service/local/artifact/maven/content```

För både frontend och backend applikationen gäller det att hantera versioner så att vi får en unik version för varje deploy till nexus,
ett enkelt sätt att lösa det är att använda en parameter från jenkins, BUILD_NUMBER. Då kan vi sätta versionen till:
``` 1.0.${BUILD_NUMBER} ```
Detta fungerar både i shell script och när man anger parametrar till ett maven bygge.
