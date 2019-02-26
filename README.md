

# kubeadm-vagrant-cluster-centos-windeos

在Windows10下，基于vagrant和centos7利用kubeadm创建一个3节点的k8s集群

## Step 1

实验主机配置 Windows10专业版，I7-8700， 16G内存128G ssd +1T机械，在Windows上安装[vagrant](https://www.vagrantup.com/)和[oracle](https://www.virtualbox.org/)虚拟机

## Step 2

安装集群的基本信息，k8s为v1.13.3，节点数目为3,pod的网络地址10.244.0.0/16

| 集群节点          | 名称| 安装的组件|
| ------------ | -------- | ---------------------------------------- |
| 192.168.55.101 | nodes1    | kubeadm, kubectl, kubelet, kube-apiserver, kube-controller-manager, kube-scheduler, etcd, docker, flannel, kube-proxy, coredns |
| 192.168.55.102 | nodes2    | kubeadm, kubectl, kubelet, docker, flannel, kube-proxy, coredns        |
| 192.168.55.103 | nodes3    | kubeadm, kubectl, kubelet, docker, flannel, kube-proxy, coredns                |

## Step 3

脚本文件使用，在目录下执行如下指令

    vagrant up
  
安装程序会输出运行的信息，预计需要4-6分钟左右完成

## Step 4

利用xshell或者其他远程登录工具，访问集群，登录用户为root，密码为1995（可以自己在脚本修改），在nodes1节点上，输入下面的命令

    kubeadm token create --print-join-command
 或者是
 
    cat ~/mycom.txt
 在节点2和3上按照命令提示将内容复制到控制台执行，随后在nodes1节点上执行
 

    kubectl get nodes
可以看到节点均已经加入，利用下面的指令可以给集群添加角色

    kubectl label nodes nodes3  node-role.kubernetes.io/slave2=
 将nodes2角色设置为slave2


