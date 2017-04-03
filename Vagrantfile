# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.ssh.forward_agent = true
  config.vm.network "forwarded_port", guest: 8001, host: 8001
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    sudo apt-get -qq update
    sudo apt-get install -yqq wget git
    export DEBUG=1
    export SKIP_LOGIN=1
    bash /vagrant/linux.sh
  SHELL
end
