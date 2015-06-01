class backendApp {
	class {'nexus':
		url      => "http://192.168.33.10:8081/nexus",
		username => "admin",
		password => "admin123"
	}

	nexus::artifact {'cicd-lab-backend':
		gav        => "se.omegapoint:cicd-lab-backend:1.0.119",
		repository => "releases",
		output     => "/opt/cicd-lab-backend/cicd-lab-backend-1.0.119.jar"
	}
}