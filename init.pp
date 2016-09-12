class backendApp {
	class {'nexus':
		url      => "http://192.168.33.10:8081/nexus",
		username => "admin",
		password => "admin123"
	}

	nexus::artifact {'cicd-workshop-backend':
		gav        => "se.omegapoint:cicd-workshop-backend:1.0.119",
		repository => "releases",
		output     => "/opt/cicd-workshop-backend/cicd-workshop-backend-1.0.119.jar"
	}
}