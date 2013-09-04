# -*- mode: ruby -*-
# vi: set ft=ruby :

require "vagrant"

if Vagrant::VERSION < "1.2.1"
  raise "Use a newer version of Vagrant (1.2.1+)"
end


# Allows us to pick a different box by setting Environment Variables
BOX_NAME = ENV['BOX_NAME'] || "precise64"
BOX_URI = ENV['BOX_URI'] || "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"

Vagrant.configure("2") do |config|
  # Cachier - speeds up subsequent runs.
  # vagrant plugin install vagrant-cachier
  config.cache.auto_detect = true
  #config.cache.enable_nfs  = true
  config.berkshelf.enabled = true
  # Ensure Chef 11.x is installed for provisioning
  config.omnibus.chef_version = :latest

  config.vm.define :SaasZNC do |config|
    config.vm.hostname = "SaasZNC"
    config.vm.box = BOX_NAME
    config.vm.box_url = BOX_URI
    config.vm.network :private_network, ip: "33.33.33.33"
    config.vm.network :forwarded_port, guest: 3000, host: 3000
    config.ssh.max_tries = 40
    config.ssh.timeout   = 120
    config.ssh.forward_agent = true
    config.vm.provision :chef_solo do |chef|
      chef.provisioning_path = "/tmp/vagrant-cache"
      chef.json = {
          "languages" => {
            "ruby" => {
              "default_version" => "1.9.1"
            }
          }
      }
      chef.run_list = [
        "recipe[apt::default]",
        "recipe[ruby::default]",
        "recipe[build-essential::default]",
        "recipe[git::default]",
        "recipe[docker::default]"
      ]
    end

    config.vm.provision :shell, :inline => <<-SCRIPT
      groupadd docker
      usermod -a -G docker vagrant
      apt-get -y -q install libxslt-dev libxml2-dev libpq-dev sqlite3 libsqlite3-dev
      gem install bundler --no-ri --no-rdoc
      cd /vagrant
      su - -c "service docker restart"
      bundle install
      echo "Create Database..."
      rake db:migrate
      echo "Start Server..."
      echo "* First login will take a while due to initial docker pull..."
      rails server -d


    SCRIPT
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--cpus", 2]
      vb.customize ["modifyvm", :id, "--memory", 2048]
    end
  end
end
