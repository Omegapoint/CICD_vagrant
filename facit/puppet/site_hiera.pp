node 'default' {	
	
	$backend_version = hiera('cicd-workshop-backend_version', 'LATEST')
	
	$gav = "se.omegapoint:cicd-workshop-backend:$backend_version"
	
	notify{"The value is: ${gav}": }
	
	class {'nexus':
		url      => "http://192.168.33.10:8081/nexus",
		username => "admin",
		password => "admin123"
	}

	nexus::artifact {'cicd-workshop-backend':
		gav        => "${gav}",
		repository => "public",
		output     => "/opt/cicd-workshop-backend/cicd-workshop-backend-$backend_version.jar"
	}
}
