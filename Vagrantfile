


Vagrant.configure("2") do |config|
	config.vm.synced_folder ".", "/vagrant"
	
	(3..3).each do |i|

		config.vm.define "nodes#{i}" do |node|

		# 设置虚拟机的Box
		node.vm.box = "centos/7"

		# 设置虚拟机的主机名
		node.vm.hostname="nodes#{i}"

		# 设置虚拟机的IP
		node.vm.network "private_network", ip: "192.168.55.#{100+i}"


		# VirtaulBox相关配置
		node.vm.provider "virtualbox" do |v|

			# 设置虚拟机的名称
			v.name = "nodes#{i}"

			# 设置虚拟机的内存大小  
			v.memory = 2048

			# 设置虚拟机的CPU个数
			v.cpus = 2
		end
			node.vm.provision "shell", path: "MyInstall.sh", args: [i]
		end
		
	end
end