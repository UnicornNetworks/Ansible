Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/disco64"

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
    node0.vm.provision "ansible" do |p|
      p.playbook = "bootstrap.yml"
      p.groups = {
        "bootstrap" => ["node0"]
      }
      p.extra_vars = {
        "sshd_admin_net" => "0.0.0.0/0",
        "ssh_allow_groups" => "vagrant sudo ubuntu",
        "ssh_max_auth_tries" => "6",
        "ansible_python_interpreter" => "/usr/bin/python3",
      }
      end
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
        "ssh_max_auth_tries" => "6",
        "ansible_python_interpreter" => "/usr/bin/python3",
      }
      end
    end
  end
end
