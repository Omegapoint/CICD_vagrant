# Setup
How to setup container volumes to be used by the other containers

## Create git-server volume with repository

Build image:

	$ docker build -t setup_image .
	
Run image to clone and store repo in volume:

	$ docker run --rm -v docker_gitdata:/gitdata setup_image clone --bare https://github.com/Omegapoint/cicd-workshop-backend.git
	
## Setup keys

Create key in local dir:
    
    $ ssh-keygen -f ~/supersecret -t rsa -N ''
    
Add key

    $ ssh-add ~/supersecret
    
Create jenkinsdata volume and store private-key

    $ docker run --rm -v docker_jenkinsdata:/jenkinsdata -v ~/:/mirror alpine cp /mirror/supersecret jenkinsdata/

Create keys volume and store public key

    $ docker run --rm -v docker_keys:/keys -v ~/:/mirror alpine cp /mirror/supersecret.pub keys/