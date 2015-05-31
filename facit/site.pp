class {'nexus':
    url      => "http://192.168.33.10:8081/nexus",
    username => "admin",
    password => "admin123"
}

exec { 'stop-app':
  command => '/usr/sbin/service cicd-lab-backend.sh stop',
} ~>
nexus::artifact {'cicd-lab-backend':
   gav        => "se.omegapoint:cicd-lab-backend:1.0",
   repository => "public",
   output     => "/opt/cicd-lab-backend/cicd-lab-backend-1.0.jar"
} ~>
exec { 'start-app':
  command => '/usr/sbin/service cicd-lab-backend.sh start'
}
