# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  require 'rbconfig'

  # Define a vagrant machine for the CONTINUOUS INTEGRATION server
  # --------------------------------------------------------------
  config.vm.define "ci" do |ci|
	  ci.vm.network "private_network", ip: "192.168.33.10"
	  ci.vm.hostname = "ci"

	  ci.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.memory = "2048"
	  end

	  if is_windows
	  	ci.vm.provision "shell" do |sh|
	  		sh.path = "playbooks/JJG-Ansible-Windows/windows.sh"
	  		sh.args = "playbooks/ci.yml"
	  	end
	  else
	  	ci.vm.provision "ansible" do |ansible|
	  		ansible.playbook = "playbooks/ci.yml"
	  	end
	  end
  end

  # Define a vagrant machine for the TEST server
  # --------------------------------------------
  config.vm.define "test" do |test|
	  test.vm.network "private_network", ip: "192.168.33.20"
	  test.vm.hostname = "test"

	  test.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.memory = "512"
	  end

	  if is_windows
	  	test.vm.provision "shell" do |sh|
	  		sh.path = "playbooks/JJG-Ansible-Windows/windows.sh"
	  		sh.args = "playbooks/test.yml"
	  	end
	  else
	  	test.vm.provision "ansible" do |ansible|
	  		ansible.playbook = "playbooks/test.yml"
	  	end
	  end
  end
  
  # Define a vagrant machine for the PROD server
  # --------------------------------------------
  config.vm.define "prod" do |prod|
	  prod.vm.network "private_network", ip: "192.168.33.30"
	  prod.vm.hostname = "prod"

	  prod.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.memory = "512"
	  end

      if is_windows
      	prod.vm.provision "shell" do |sh|
      		sh.path = "playbooks/JJG-Ansible-Windows/windows.sh"
      		sh.args = "playbooks/prod.yml"
      	end
      else
      	prod.vm.provision "ansible" do |ansible|
      		ansible.playbook = "playbooks/prod.yml"
      	end
      end
  end
end
