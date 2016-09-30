Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end

  (1..3).each do |i|
    config.vm.define "node#{i}" do |node|
    config.vm.network "private_network", ip:"192.168.13.1#{i}"
    config.vm.hostname = "node#{i}"
    node.vm.provision "ansible" do |p|
      p.playbook = "bootstrap.yml"
      p.groups = {
        "bootstrap" => ["node#{i}"]
      }
      p.extra_vars = {
        "sshd_admin_net" => "0.0.0.0/0"
      }
      end
    end
  end
end
