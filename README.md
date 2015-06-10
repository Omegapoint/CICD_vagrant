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

6. Installera python 2.6 eller 2.7 och pip.
7. Installera ansible
   ```sudo pip install ansible```

8. Kör ```vagrant up``` i den klonade projektkatalogen. 
 - Om den definierade timeouttiden inte räcker till så kan utökas genom att lägga till config.vm.boot_timeout = 3000 (efter config.vm.box) i Vagrantfile. På Windows är det sannolikt är det dock inte ett timeoutproblem utan att Windows ibland har svårt att hantera virtuella 64-bitars system. Byt i så fall till config.vm.box = "ubuntu/trusty32" istf config.vm.box = "ubuntu/trusty64".
9. Vänta (kan ta upp emot 45 min)

### Konfigurera Puppet

I labben är det tänkt att man använder sig utav Puppet för att genomföra deployer till test- och prodmaskinen. Puppet är uppsatt så att det finns en Puppet-master på ci-maskinen och och en slav på vardera test- och prod-maskinen. Slavarna pollar mastern efter ändringar och om så är fallet utför slavarna ändringarna på respektive maskin. För att det skall fungera måste certifikat signeras på följande sätt:

1. Anslut till ci-maskinen med ````vagrant ssh ci``` och kör ```sudo puppet master --verbose --no-daemonize``` för att skapa nya CA certifikat.
2. När certifikat och SSL-nycklar har skapats startas puppet och ```Notice: Starting Puppet master version 3.6.2``` syns i terminalfönstret. Avbryt då med Ctrl-C
3. Kör ```sudo service apache2 start``` istället för att starta Puppet
4. Logga ut från ci-maskinen och anslut till test-maskinen med ```vagrant ssh test```
5. Starta Puppet-slaven med ```sudo service puppet start```
6. Upprepa 4 och 5 för prod-maskinen
7. Anslut till ci-maskinen och signera slavarnas certifikat med ```sudo puppet cert sign --all```

På ci-maskinen kan aktuella certifikat listas med ```sudo puppet cert list```
På test- och prod-maskinen kan slavarnas kontakt med mastern testas med ```sudo puppet agent --test```

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

##Uppgift 2
Nu ska vi vidareutveckla vår byggpipeline så att vi för varje stabilt bygge skapar och arkiverar artefakter i jenkins men vi skickar inte upp något till nexus.
Istället ska uppladdning till nexus ske via en promotion, för detta behöver vi använda två plugins: Parameterized trigger plugin och promoted builds plugin.
Alla plugins nödvändiga för labben är installerade som default.
För att kunna använda promotions behöver vi göra följande:

1. Första steget är att i deployjobbet lägga till ett promotion steg (Promote builds when...)
2. Vi behöver ha ett antal parametrar (predefined parameters): BuildVal, Promoted_Build_Number, JobName. 
BuildVal är lite speciellt, den ska sättas till:

``` <SpecificBuildSelector><buildNumber>$PROMOTED_NUMBER</buildNumber></SpecificBuildSelector> ```

3. Checka i only when manually approved och block until the triggered projects finish their builds

Vi måste också ange ett projekt att bygga när promotion görs, nästa steg är att sätta upp det jobbet. Detta jobb ska kopiera artefakter från det jobb som gör anropet, dvs vårt promotion jobb.
Vi måste därför använda copy artifact plugin, ange att jobbet är parameteriserat och sätt upp tre parametrar som matchar de parametrar som vi satte upp i förra jobbet. 
BuildVal ska vara av typen "build selector for copy artifact", de andra två strängar.

För att sätta versionen när vi laddar upp till nexus kan vi använda promoted_build_number som vi får in som parameter:
``` 1.0.${PROMOTED_BUILD_NUMBER} ```

##Uppgift 3

Uppgift tre går ut på att deploya artifakterna från Nexus till test- och prodmiljön m.h.a. Puppet. Puppet har ett deklarativt språk där man i något som kallas för manifest beskriver vilket tillstånd man vill att en systemresurs, t.ex. en av maskinerna i labben, ska ha. Puppet fungerar så att manifestet på mastern propageras ut till slavarna som verkställer ev. tillståndsändringar. 

Idén är att man i manifestet beskriver hur backend- och frontendappen installeras och vilken version av appen som gäller. När någon av slavarna ser att en förändring skett i versionsnummer deployas den nya versionen ut. Test- och prodmaskinen är slavar till Puppet mastern som finns på ci-maskinen. Huvudmanifestet finns i ```/etc/puppet/manifests/site.pp``` på ci-maskinen.

Tips:

Puppet i labben finns förberett med en Nexus-modul som kan hämta artifakter från Nexus på följande sätt:

```
class { 'nexus':
  url      => "http://192.168.33.10:8081/nexus",
  username => "admin",
  password => “admin123”
}

nexus::artifact { 'cicd-lab-backend':
  gav        => "se.omegapoint:cicd-lab-backend:12",
  repository => "public",
  output     => "/opt/cicd-lab-backend/cicd-lab-backend-12.jar",
  ensure     => "update"
}
```

Vilka versionsnummer av backend- och frontendappen som är aktuella för deploy kan lämpligen hanteras med Hiera som även det finns uppsatt i Puppetinstallationen på ci-maskinen. I Hieras yaml-filer under ```/etc/puppet/hieradata``` kan man hålla aktuella versionnummer och separera ändringar av dessa från själva deploykonfigurationen i Puppet-manifestet. Det finns en common yaml-fil och två separata för test- och prodmaskinerna.

I sitt manifest kan man komma åt properties satta i yaml-filerna så här: 
```$backend_version = hiera("cicd-lab-backend_version")```

På test- och prodmaskinerna finns det ett init.d skript som kan starta och stoppa backendappen, ```service cicd-lab-backend.sh [start|stop]```, vilket gör att det räcker att hämta ner fetjar:en från Nexus när en ny version ska ut.

##Stretch goals
1. På ci-maskinen finns det en sonarserver som kan användas för att lägga till ett byggsteg som granskar en applikations kodkvalitet. 
   Mer information om Sonar och hur man kan integrera Sonar med Jenkins finns här: http://docs.sonarqube.org/display/SONAR/Documentation.
   
2. CI-maskinen provisioneras med hjälp av ansible, skriv om provisioneringsscripten för test och prod boxen så att dessa också provisioneras med hjälp av ansible. 