# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "puphpet/ubuntu1404-x64"
  config.vm.hostname = 'hadoop-precise64'
  config.vm.provision "shell", path: "postinstall.sh"
  config.vm.network :forwarded_port, guest: 50070, host: 50070
  config.vm.network :forwarded_port, guest: 50030, host: 50030

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
  end

end
