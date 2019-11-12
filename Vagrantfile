Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/disco64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end

  (1..3).each do |i|
    config.vm.define "node#{i}" do |node|
    config.vm.network "private_network", ip:"10.2.3.4#{i}"
    config.vm.hostname = "node#{i}"
    config.vm.boot_timeout = 600
    config.vm.provision "shell",
      inline: "apt-get update && apt-get -y install python3-pexpect --no-install-recommends"
    node.vm.provision "ansible" do |p|
      p.playbook = "bootstrap.yml"
      p.groups = {
        "bootstrap" => ["node#{i}"]
      }
      p.extra_vars = {
        "sshd_admin_net" => "0.0.0.0/0",
        "ssh_allow_groups" => "vagrant sudo ubuntu",
        "ansible_python_interpreter" => "/usr/bin/python3"
      }
      end
    end
  end
end
