Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.default_nic_type = "Am79C973"
  end

  config.vm.define "disco" do |disco|
    disco.vm.box = "ubuntu/disco64"
    disco.ssh.insert_key = true
    disco.vm.network "private_network", ip: "10.2.3.40"
    disco.vm.hostname = "disco"
    disco.vm.boot_timeout = 600
    disco.vm.provision "shell",
      inline: "apt-get update && apt-get -y install python3-pexpect --no-install-recommends"
  end

  (1..2).each do |i|
    config.vm.define "bionic#{i}" do |bionic|
      bionic.vm.box = "ubuntu/bionic64"
      bionic.vm.network "private_network", ip:"10.2.3.4#{i}"
      bionic.vm.hostname = "bionic#{i}"
      bionic.vm.boot_timeout = 600
      bionic.vm.provision "shell",
        inline: "apt-get update && apt-get -y install python3-pexpect --no-install-recommends"
    end
  end

  config.vm.define "suse" do |suse|
    suse.vm.box = "opensuse/Tumbleweed.x86_64"
    suse.ssh.insert_key = true
    suse.vm.network "private_network", ip: "10.2.3.43"
    suse.vm.hostname = "suse"
    suse.vm.boot_timeout = 600
    suse.vm.provision "shell",
      inline: "hostnamectl set-hostname suse"
  end

  config.vm.define "centos" do |centos|
    centos.vm.box = "bento/centos-8"
    centos.ssh.insert_key = true
    centos.vm.network "private_network", ip: "10.2.3.44"
    centos.vm.provider "virtualbox" do |c|
      c.default_nic_type = "82543GC"
    end
    centos.vm.hostname = "centos"
    centos.vm.boot_timeout = 600
  end

  config.vm.define "fedora" do |fedora|
    fedora.vm.box = "bento/fedora-30"
    fedora.ssh.insert_key = true
    fedora.vm.network "private_network", ip: "10.2.3.45"
    fedora.vm.hostname = "fedora"
    fedora.vm.boot_timeout = 600
  end

  config.vm.define "buster" do |buster|
    buster.vm.box = "bento/debian-10"
    buster.ssh.insert_key = true
    buster.vm.network "private_network", ip: "10.2.3.42"
    buster.vm.hostname = "buster"
    buster.vm.boot_timeout = 600
  end
end
