# K8s 使用教程


参考链接：

- [ubuntu 使用阿里云镜像源快速搭建 kubernetes 1.15.2 集群](https://www.cnblogs.com/xiao987334176/p/11317844.html)

# 安装

```bash
sudo apt-get update &amp;&amp; sudo apt-get install -y apt-transport-https curl
echo &#34;deb https://apt.kubernetes.io/ kubernetes-xenial main&#34; | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

## 安装最新版
sudo apt install -y kubelet=1.18.5-00 kubeadm=1.18.5-00 kubectl=1.18.5-00
sudo apt-mark hold kubelet=1.18.5-00 kubeadm=1.18.5-00 kubectl=1.18.5-00

# sudo apt-get install -y kubelet kubeadm kubectl
# sudo apt-mark hold kubelet kubeadm kubectl
```

## 更新 kubeadm

参考：[升级 kubeadm 集群](https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

# 设置

## 禁用 swap

所有主机禁用 `swap`

```bash
sudo sed -i &#39;/swap/ s/^/#/&#39; /etc/fstab
sudo swapoff -a
```

## 安装 Docker

所有主机均需要安装 `Docker`

## 安装 kubelet, kubeadm, kubectl

所有主机需要安装

## 主机安装 kubernetes 集群

```bash
sudo kubeadm init --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.18.5 --pod-network-cidr=192.169.0.0/16 | tee /etc/kube-server-key
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-08-06-k8s-%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/  

