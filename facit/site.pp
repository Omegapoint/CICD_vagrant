define backend_app($version) { 

    class {'nexus':
        url      => "http://192.168.33.10:8081/nexus",
        username => "admin",
        password => "admin123"
    }

    file { "/opt/cicd-lab-backend":
        ensure => "directory",
    } ->
    exec { 'stop-app':
        command => '/usr/sbin/service cicd-lab-backend.sh stop'
    } ->
    exec { 'clean dir':
        command => '/usr/bin/find /opt/cicd-lab-backend -name "*.jar" -exec rm -f {} \;'
    } ->
    nexus::artifact {'cicd-lab-backend':
        gav        => "se.omegapoint:cicd-lab-backend:${version}",
        repository => "public",
        output     => "/opt/cicd-lab-backend/cicd-lab-backend-${version}.jar",
        ensure     => "update"
    } ->
    exec { 'start-app':
        command => '/usr/sbin/service cicd-lab-backend.sh start'
    }
}

node 'test' {
    backend_app { 'backend_app':
    version => '1.0.8'
    }
}

node 'prod' {
    backend_app { 'backend_app':
    version => '1.0.7'
    }
}

