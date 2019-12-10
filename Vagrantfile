Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.default_nic_type = "Am79C973"
  end

  config.vm.define "node0" do |node0|
    node0.vm.box = "ubuntu/disco64"
    node0.ssh.insert_key = true
    node0.vm.network "private_network", ip: "10.2.3.40"
    node0.vm.hostname = "node0"
    node0.vm.boot_timeout = 600
    node0.vm.provision "shell",
      inline: "apt-get update && apt-get -y install python3-pexpect --no-install-recommends"
  end

  (1..2).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "ubuntu/bionic64"
      node.vm.network "private_network", ip:"10.2.3.4#{i}"
      node.vm.hostname = "node#{i}"
      node.vm.boot_timeout = 600
      node.vm.provision "shell",
        inline: "apt-get update && apt-get -y install python3-pexpect --no-install-recommends"
    end
  end
end
