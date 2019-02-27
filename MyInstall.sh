

echo "进入root用户，修改root用户密码"
sudo su
#设定密码为1995
echo root:1995 |sudo chpasswd root

echo "修改远程登录权限"
sudo sed -i 's/#PermitRootLogin\ yes/PermitRootLogin\ yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config
#重新启动sshd服务，确保生效
systemctl restart sshd


echo "下载必要的文件"
yum install -y wget curl vim net-tools telnet tcpdump bind-utils socat ntp yum-utils device-mapper-persistent-data lvm2


echo "修改host文件，将集群IP加入"
echo "192.168.55.101 nodes1" >> /etc/hosts
echo "192.168.55.102 nodes2" >> /etc/hosts
echo "192.168.55.103 nodes3" >> /etc/hosts


echo "禁用防火墙"
sudo  systemctl stop firewalld
sudo systemctl disable firewalld


echo "禁用Selinux"
setenforce 0
sed -i 's/enforcing/disabled/' /etc/selinux/config

echo "使能iptable转发"
cat >> /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF
#生效配置
modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

echo "禁用交换"
swapoff -a

echo "step1：安装docker，实验用的是k8s1.13.0，对应的最高版本是docker18.06"
yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum install -y --setopt=obsoletes=0 docker-ce-18.06.1.ce-3.el7

echo "启动docker"


systemctl enable docker
systemctl start docker



echo "step2:设置阿里镜像源"
cat  > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum makecache fast

echo "安装kubelet、kubeadm和kubectl"
yum install -y kubelet kubeadm kubectl

#在kubelet中去掉关闭swap的限制

sed -i 's/=/=--fail-swap-on=false/g'  /etc/sysconfig/kubelet

echo "每个节点启动kubelet，可能无法启动，等初始化均完成，就正常了"
systemctl daemon-reload
systemctl enable kubelet.service
systemctl start kubelet.service


com=""
if [[ $1 -eq 1 ]]
then
  
  echo "step3：离线载入所需镜像"
  python /vagrant/mymasterload.py
	#主机节点为192.168.55.101
  echo "step4：主节点操作"
	kubeadm init \
  --kubernetes-version=v1.13.0 \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=192.168.55.101 \
  --ignore-preflight-errors=Swap
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  #指定网卡
  kubectl apply -f  /vagrant/kube-flannel.yml
  #将加入指令写入文件
  echo "获取加入指令"
  echo $(kubeadm token create --print-join-command) > mycom.txt
  
fi

if [[ $1 -eq 2 ]]
then
 
  python /vagrant/mynodeload.py
  echo "step5 :node节点操作"
  #手动添加节点
fi

if [[ $1 -eq 3 ]]
then
  python /vagrant/mynodeload.py
  echo "step5 :node节点操作"
  #手动添加节点
fi


#在主节点登录，可以kubeadm token create --print-join-command查看接入指令，也可以根据mycom.txt内容加入集群
#给集群添加角色，kubectl label nodes nodes3  node-role.kubernetes.io/slave2= 将nodes2设置为slave2


