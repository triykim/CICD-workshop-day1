# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Ubuntu 24.04 LTS (Noble Numbat)
  config.vm.box = "bento/ubuntu-24.04"
  
  # Configure VM resources
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "jenkins-workshop"
  end
  
  # Network configuration - forward Jenkins port
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "private_network", ip: "192.168.56.10"
  
  # Hostname
  config.vm.hostname = "jenkins-workshop"
  
  # Provision script to update system
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get upgrade -y
    
    # Install prerequisites
    apt-get install -y curl git wget software-properties-common tree
    
    echo "========================================"
    echo "VM is ready!"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "  1. Install Jenkins: sudo /vagrant/scripts/install-jenkins.sh"
    echo "  2. Access Jenkins: http://localhost:8080"
    echo "  3. Build Go app: cd /vagrant && ./scripts/build.sh"
    echo ""
    echo "Project structure:"
    tree -L 2 /vagrant -I 'bin|artifacts|.vagrant' --dirsfirst
  SHELL
end
