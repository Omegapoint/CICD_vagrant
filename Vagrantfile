# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Define a vagrant machine for the CONTINUOUS INTEGRATION server
  # --------------------------------------------------------------
  config.vm.define "ci" do |ci|
      # Create a private network, which allows host-only access to the machine
	  # using a specific IP.
	  ci.vm.network "private_network", ip: "192.168.33.10"

	  ci.vm.hostname = "ci"

	  # Provider-specific configuration so you can fine-tune various
	  # backing providers for Vagrant. These expose provider-specific options.
	  # Example for VirtualBox:
	  #
	  ci.vm.provider "virtualbox" do |vb|
		# Display the VirtualBox GUI when booting the machine
		vb.gui = false
		# Customize the amount of memory on the VM:
		vb.memory = "2048"
	  end

	  # Enable provisioning with a shell script. Additional provisioners such as
	  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
	  # documentation for more information about their specific syntax and use.
	  # config.vm.provision "shell", inline: <<-SHELL
	  #   sudo apt-get update
	  #   sudo apt-get install -y apache2
	  # SHELL  
#	  ci.vm.provision :shell, path: "bootstrap_ci.sh"
          ci.vm.provision "ansible" do |ansible|
             ansible.playbook = "playbooks/ci.yml"
          end
  end


  # Define a vagrant machine for the TEST server
  # --------------------------------------------
  config.vm.define "test" do |test|
      # Create a private network, which allows host-only access to the machine
	  # using a specific IP.
	  test.vm.network "private_network", ip: "192.168.33.20"

	  test.vm.hostname = "test"

	  # Provider-specific configuration so you can fine-tune various
	  # backing providers for Vagrant. These expose provider-specific options.
	  # Example for VirtualBox:
	  #
	  test.vm.provider "virtualbox" do |vb|
		# Display the VirtualBox GUI when booting the machine
		vb.gui = false
		# Customize the amount of memory on the VM:
		vb.memory = "512"
	  end

	  # Enable provisioning with a shell script. Additional provisioners such as
	  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
	  # documentation for more information about their specific syntax and use.
	  # config.vm.provision "shell", inline: <<-SHELL
	  #   sudo apt-get update
	  #   sudo apt-get install -y apache2
	  # SHELL  
	  test.vm.provision :shell, path: "bootstrap_test.sh"
  end
  
  
  # Define a vagrant machine for the PROD server
  # --------------------------------------------
  config.vm.define "prod" do |prod|
      # Create a private network, which allows host-only access to the machine
	  # using a specific IP.
	  prod.vm.network "private_network", ip: "192.168.33.30"

	  prod.vm.hostname = "prod"

	  # Provider-specific configuration so you can fine-tune various
	  # backing providers for Vagrant. These expose provider-specific options.
	  # Example for VirtualBox:
	  #
	  prod.vm.provider "virtualbox" do |vb|
		# Display the VirtualBox GUI when booting the machine
		vb.gui = false
		# Customize the amount of memory on the VM:
		vb.memory = "512"
	  end

	  # Enable provisioning with a shell script. Additional provisioners such as
	  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
	  # documentation for more information about their specific syntax and use.
	  # config.vm.provision "shell", inline: <<-SHELL
	  #   sudo apt-get update
	  #   sudo apt-get install -y apache2
	  # SHELL  
	  prod.vm.provision :shell, path: "bootstrap_prod.sh"
  end
end
