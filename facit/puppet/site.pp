class { 'nexus':
  url      => "http://192.168.33.10:8081/nexus",
  username => "admin",
  password => "admin123"
}

define backend_app($version) {

  file { "/opt/cicd-lab-backend":
    ensure => "directory"
  } ->
  exec { 'stop-app':
    command => '/usr/sbin/service cicd-lab-backend.sh stop'
  } ->
  exec { 'clean dir':
    command => '/usr/bin/find /opt/cicd-lab-backend -name "*.jar" -exec rm -f {} \;'
  } ->
  nexus::artifact { 'cicd-lab-backend':
    gav        => "se.omegapoint:cicd-lab-backend:${version}",
    repository => "public",
    output     => "/opt/cicd-lab-backend/cicd-lab-backend-${version}.jar",
    ensure     => "update"
  } ->
  exec { 'start-app':
    command => '/usr/sbin/service cicd-lab-backend.sh start'
  }
}

define frontend_app($version) {

  nexus::artifact { 'cicd-lab-frontend':
    gav        => "se.omegapoint:cicd-lab-frontend:${version}",
    repository => "public",
    packaging  => 'tar.gz',
    output     => "/var/tmp/cicd-lab-frontend-${version}.tar.gz",
    ensure     => "update"
  } ->
  exec { "untar":
    command => "/bin/tar xzvf /var/tmp/cicd-lab-frontend-${version}.tar.gz -C /var/www/html/"
  }

}

node 'default' {

  $backend_version = hiera("cicd-lab-backend_version")
  $frontend_version = hiera("cicd-lab-frontend_version")

  backend_app { 'backend_app':
    version => $backend_version
  } ->
  frontend_app { 'frontend_app':
    version => $frontend_version
  }

}
