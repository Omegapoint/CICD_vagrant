#CI/CD - Skapa din egen byggpipeline

##Förberedelser

1. Installera git och ssh
 - Windows: https://msysgit.github.io/ Välj förvalda alternativ
 - Mac OS: Använd ‘port’ (https://www.macports.org/), ‘fink’ (http://www.finkproject.org/) eller någon annan väg
2. Ladda ner och installera VirtualBox (https://www.virtualbox.org)
3. Gå till https://www.vagrantup.com/ och ladda ner respektive installationspaket för din dator.
4. Installera paketet och starta om datorn
5. Klona git-repot med vagrantkonfiguration och provisioneringsskript i lämplig katalog:

```$ git clone https://github.com/Omegapoint/CICD_vagrant.git```

6. Installera python 2.6 eller 2.7 och pip.
7. Installera ansible
   ```sudo pip install ansible```

8. Kör ```vagrant up``` i den klonade projektkatalogen.
 - Om den definierade timeouttiden inte räcker till så kan utökas genom att lägga till config.vm.boot_timeout = 3000 (efter config.vm.box) i Vagrantfile. På Windows är det sannolikt är det dock inte ett timeoutproblem utan att Windows ibland har svårt att hantera virtuella 64-bitars system. Byt i så fall till config.vm.box = "ubuntu/trusty32" istf config.vm.box = "ubuntu/trusty64".

9. Vänta (kan ta upp emot 45 min)

Ibland kan ett enskilt steg i provisionering fallera pga exv att en nedladdning timear ut. I så fall kan man köra om provisioneringen med ```vagrant reload --provision <maskinnamn>````. Delar av provisionering som har lyckats kommer då inte att köras om.


##Förutsättningar

Det finns tre virtuella maskiner i labben. Den första, ci/cd-maskinen, innehåller Jenkins, Sonar och de två git-repona med labbens testapplikationer. Vidare finns två maskiner, test och prod, som simulerar en test- respektive produktionsmiljö.

Man kan nå maskinerna m.h.a. ```vagrant ssh <maskinens vagrantnamn>```

###CI/CD-maskin

####Allmänt:
 - OS: Ubuntu 14.04.1 LTS (Trusty Tahr)
 - IP: 192.168.33.10
 - Vagrantnamn: ci
 - Minne: 2 GB
 - Java: Oracle JDK 8

####Jenkins:
http://192.168.33.10:8080

####Nexus:
http://192.168.33.10:8081/nexus

user: admin
password: admin123

####Sonar:
http://192.168.33.10:9000

user: admin
password: admin

####Git:

För att kunna arbeta mot de två git-repon som finns på behövs en uppsättning SSH-nycklar. Börja med att se efter om du redan har en publik nyckel:

```$ ls -al ~/.ssh```

Finns en .pub-fil som t.ex. id_rsa.pub finns det redan en nyckeluppsättning, annars behöver det genereras:

```$ ssh-keygen -t rsa```

Därefter kan din publika nyckel adderas till authorized_keys hos git-användaren:

```$ cat ~/.ssh/id_rsa.pub | ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@192.168.33.10 "sudo tee -a /home/git/.ssh/authorized_keys"```

Får du upp en lösenordsprompt är lösenordet till vagrant-användaren 'vagrant'.

De två applikationerna kan sedan klonas som vanligt:

```$ git clone git@192.168.33.10:cicd-workshop-backend.git```

```$ git clone git@192.168.33.10:cicd-workshop-frontend.git```

###TEST-maskin

####Allmänt:
 - OS: Ubuntu 14.04.1 LTS (Trusty Tahr)
 - IP: 192.168.33.20
 - Vagrantnamn: test
 - Minne: 512 MB
 - Java: Oracle JDK 8
 - Apache webserver
 - Jetty 8 (/usr/share/jetty8)

###PROD-maskin

####Allmänt:
 - OS: Ubuntu 14.04.1 LTS (Trusty Tahr)
 - IP: 192.168.33.30
 - Vagrantnamn: prod
 - Minne: 512 MB
 - Java: Oracle JDK 8
 - Apache webserver
 - Jetty 8 (/usr/share/jetty8)

###Backendapplikationen

Backendapplikationen är skriven i Java, använder sig utav Spring boot och har ett par enhetstester.

Gitrepo: git@192.168.33.10:cicd-workshop-backend.git

 - Bygg:

```$ mvn clean package```

 - Packa upp tar.gz:en i lämplig katalog t.ex.:

```$ tar xzvf target/cicd-workshop-backend-1.0-bin.tar.gz -C ~```

 - Starta applikationen:

```$ cd ~/cicd-workshop-backend-1.0 && ./application.sh start```

 - application.sh-skriptet kan bl.a. starta, stoppa och visa status:

```$ ./application.sh [start|stop|restart|debug|status]```

På test- och prodmaskinerna finns det ett init.d skript som kan starta och stoppa backendappen, ```service cicd-workshop-backend.sh [start|stop]```, vilket gör att det räcker att hämta ner fetjar:en från Nexus när en ny version ska ut.

På windowsmaskiner kan man behöva ändra ```ps -p``` till ```ps p``` i application.sh-skriptet för att få det att fungera.

###Frontendapplikationen

Frontendapplikationen är byggd m.h.a. AngularJs och innehåller även ett par enhetstester. På både test- och prodmaskinen finns det en Apache webserver som kan användas när frontendapplikationen ska deployas.

Gitrepo: git@192.168.33.10:cicd-workshop-frontend.git

 - Installera först node, sedan:

```$ npm install -g grunt-cli```

```$ npm install -g bower```

```$ npm install```

```$ bower install```

 - Köra applikationen:

```$ grunt serve```

 - Köra tester:
   Här behöver phantomjs och karma-phantomjs-launcher vara installerade.

```$ grunt test```

 - Bygga applikationen:

```$ grunt build```

 - Skapa /var/www/html/mc-angular/config/settings.json i testmiljön med följande innehåll:

```{ "REST_ENDPOINT": "http://192.168.33.20:8080" }```

 - Skapa /var/www/html/mc-angular/config/settings.json i prodmiljön med följande innehåll:

```{ "REST_ENDPOINT": "http://192.168.33.30:8080" }```

##Målbild

Målet med labben är att sätta upp två fungerande byggpipelines: för backend- respektive frontendapplikationen som finns i ci-maskinens två gitrepon. Byggpipelinerna ska bygga, testa och deploya applikationen till test-miljön automatiskt och ett bygge ska triggas på push till applikationens gitrepo. Byggpipelinerna görs lämpligtvis som en serie kedjade Jenkinsjobb och kan visualiseras m.h.a. Jenkins Build Pipeline-plugin. Ett sista manuellt triggat steg ska kunna deploya ett bygge till produktionsmiljön. Om en push till gitrepot innehåller enhetstester som inte är gröna ska bygget fallera.

##Labbinstruktioner

###Del 1 - Konfigurera jenkinsjobb
Efter att vagrant satt up boxarna så körs en jenkinsserver på ci-boxen, den kommer du åt via http://192.168.33.10:8080
Det första du behöver göra är att konfigurera två jobb, ett för frontend applikationen och ett för backend applikationen.
Jobben ska inledningsvis checka ut koden från git, köra enhetstester och sedan bygga applikationen.
Backendjobbet ska konfigureras som ett maven projekt, medan frontend applikationen ska konfigureras som ett free-style projekt.

###Del 2 - Konfigurera git och jenkins
Börja med att följa instruktionerna angående git och git-projekten. Det finns två metoder, den enklaste är att man låter Jenkins polla git-repot efter ändringar och den lite mer komplicerade men snyggare är att konfigurera git så att en incheckning notifierar jenkins att köra ett bygge. För att få git-repot att notifiera Jenkins kan man lägga till en git-hook, som triggas om något har förändrats efter en push till origin. 
Utför följande steg:

I Jenkinsjobben, checka i “poll SCM”, men utelämna tidsinställningarna. Testa att jenkins svarar på följande GET-anrop: http://192.168.33.10:8080/git/notifyCommit?url=git@192.168.33.10:<reponamn>
För bägge applikationerna, lägg in följande script i en fil med namnet post-receive. Den ska ligga i hooks katalogen för respektive repo på ci boxen: 
```bash
#!/bin/sh 
curl http://192.168.33.10:8080/git/notifyCommit?url=git@192.168.33.10:<reponamn>
```
Sätt ägare på filen och gör den exekverbar genom: ```sudo chown git:git post-receive```, ```sudo chmod +x post-receive``` Verifiera att push-tekniken fungerar genom att i host-miljön checka ut applikationerna, gör en förändring i någon fil och pusha förändringarna till git servern. Då ska ett nytt bygge exekveras på jenkinsservern.

###Del 3 - Testautomatisering
Nu när du har applikationerna utcheckade och två jobb konfigurerade som exekverar byggen på push till git så ska du lägga till eller modifera tester i applikationerna. I javaapplikationen skrivs tester med junit och spring framework. I frontend applikationen skrivs tester med jasmine. Skriv ett test som fallerar och checka in koden, du ska sedan se i jenkins att bygget markeras som fallerat. Ändra i testklassen så att alla tester går igenom, pusha koden och verifiera i jenkins.

###Del 4 - Continuous delivery
I denna del ska du skapa deployjobb som automatiskt installerar applikationerna i test och prodmiljö. 

####Frontendapplikationen

Vi kommer används rpm och programmet fpm för att skapa rpm:er.
Utför följande steg:

1. I ditt första jobb, lägg till att applikationen taggas i git för stabila byggen. Sedan ska du bygga ett annat projekt när bygget är stabilt, vilket blir deployjobbet.
2. Skapa ett deployjobb som kopierar artefakter från ett annat projekt, välj det jobb som du tidigare jobbat med.
3. Sätt upp en sträng parameter till jobbet, denna parameter kommer innehålla byggnummret för artefakten som ska skapas och installeras.
4. Skriv ett shellscript i bygget som utför följande (exempel frontendapp):
```cd dist``` följt av
```fpm -s dir -t rpm -n mc-angular -v 1.0.${Param} --verbose --directories mc-angular --category op/application  --description "Angular-applikation mc-angular"  --rpm-user vagrant --rpm-group vagrant --rpm-defattrfile 644 --rpm-defattrdir 755 --prefix /var/www/html mc-angular```
5. Skicka filen till testmiljön genom: ```rsync -v -e ssh "mc-angular-1.0."${Param}"-1.x86_64.rpm" jenkins@192.168.33.20:~```
6. Skapa en ssh-inloggning mot testmiljön med ssh plugin och kör följande script: 
```bash
cd /home/jenkins
rpm -ivh "mc-angular-1.0."${Param}"-1.x86_64.rpm"
```

####Backendapplikationen
Det enklaste sättet är att deploya applikationen är som följer:

1. Skapa ett nytt deployjobb som kopierar artifakter från det jobb som du först skapade för att bygga och testa applikationen.
2. Lägg till en trigger i ditt första byggjobb som om det första jobbet har lyckats triggar den nya deployjobbet. Låt även det första jobbet skicka med byggnumret som parameter till deployjobbet.
3. Använd byggnummerparametern från det första jobbet för att kopiera rätt artifakt.
4. Själva deployen görs i fyra steg och kan köras som ett shellskript i ett jenkinsjobb:
 1. Stoppa applikationen på servern
 2. Radera föregående artifakt
 3. Kopiera (m.h.a. scp eller rsync) ut den nya artfakten till servern
 4. Starta applikationen på servern

På test- och prodmaskinerna finns det ett init.d-skript ```/etc/init.d/cicd-workshop-backend``` som kan starta och stoppa applikationen. Skriptet förutsätter att applikationens jar:er placeras i ```/opt/cicd-workshop-backend```.

##Stretch goals

### Hantera artifakter m.h.a. Nexus

Istället för att kopiera runt artifakter mellan olika Jenkinsjobb kan man hantera byggartifakter på ett mer ordnat sätt m.h.a. en repository manager. På ci-maskinen finns Nexus installerad för detta ändamål. Processen med Nexus blir att man låter byggjobben vid ett lyckat bygge ladda upp den artfakt som byggts till Nexus och att sedan deployjobben hämtar den artifakt som ska deployas från Nexus. Nexus hjälper till med att arkivera byggda artifakter och underlättar distributionen.

Backendapplikationens artifakt kan laddas upp till Nexus m.h.a. Maven:

```bash
mvn deploy:deploy-file \  
-DgroupId=se.omegapoint \  
-DartifactId=cicd-workshop-backend \  
-Dversion=1.0.${BUILD_NUMBER} \  
-Dpackaging=jar \  
-Dfile=/var/lib/jenkins/jobs/backend-build-nexus/builds/${BUILD_NUMBER}/archive/target/cicd-workshop-backend-1.0.${BUILD_NUMBER}.jar \  
-DrepositoryId=deployment \  
-Durl=http://192.168.33.10:8081/nexus/content/repositories/releases \  
--settings=/var/lib/jenkins/.m2/settings.xml
```

Enklaste sättet att hämta artifakter från Nexus är att ladda ner dem med curl eller wget. Exempel med curl: ```curl -O http://192.168.33.10:8081/nexus/service/local/repositories/releases/content/se/omegapoint/cicd-workshop-backend/1.0.${PROMOTED_BUILD_NUMBER}/cicd-workshop-backend-1.0.${PROMOTED_BUILD_NUMBER}.jar -o /opt/cicd-workshop-backend```

### Deploy m.h.a. Ansible

Deployprocesserna ovan består i att man från Jenknis med små bashscript distribuerar ut och startar artifakter. Ett bättre sätt att hantera deploy på är att använda sig utav ett verktyg som är till för att underlätta just driftsättning. Ett förslag är att använda sig av Ansible, http://ansible.com/, som abstraherar bort allt ssh:ande och har en enkel yaml-syntax för att beskriva en deployprocess. Genom att inte ha deployprocessen beskriven direkt i Jenkinsjobben öppnar också upp möjligheten till att versionshantera deployskripten och deploykonfigurationen vilket alltid är att föredra. Ansible finns redan installerat på ci-maskinen och det finns också ett git-repo på samma maskin, ```git@192.168.33.10:cicd-lab-ansible.git```, med ett skelett för att komma igång med Ansible. 

### Sonar och statisk kodanalys

På ci-maskinen finns det en sonarserver som kan användas för att lägga till ett byggsteg som granskar en applikations kodkvalitet. Mer information om Sonar och hur man kan integrera Sonar med Jenkins finns här: http://docs.sonarqube.org/display/SONAR/Documentation.

### Promoted Builds Plugin

För att få bättre spårbarhet och kontroll över vilka byggen som är okej att tas till produktion kan man använda sig utav Jenkins Promoted Builds Plugin: https://wiki.jenkins-ci.org/display/JENKINS/Promoted+Builds+Plugin

Ett tänkbart flöde när man använder denna plugin kan vara att skapa ett jenkinsjobb som utför promote-logik, t.e.x gör en secure copy till produktionsmiljö. Jobbet tar som inparametrar ett jobbnamn och byggnummer, så att artefakter från det jobb som triggat promotion kan användas vid deploy.
För att kunna skicka in parametrarna till promotejobb väljer man predefined parameters under Trigger/call builds on other projects. Ange sedan:

Jobb=$PROMOTED_JOB_NAME
Byggval=<SpecificBuildSelector><buildNumber>$PROMOTED_NUMBER</buildNumber></SpecificBuildSelector>

Du måste också ange att jobbet som triggar en promotion arkiverar sina artefakter så att promote-jobbet kan få tillgång till dessa.
