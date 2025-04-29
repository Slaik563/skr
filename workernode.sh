#!/bin/bash

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo swapoff -a


echo '----------receiving key gpg---------------------------------------------------'
sudo mkdir -p /etc/apt/keyrings/
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo '----------receiving key done--------------------------------------------------'

echo '----------Opening ports------------------------------------------------------'
sudo ufw allow OpenSSH
sudo ufw enable 
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 179
echo '----------opening ports done-------------------------------------------------'

sudo apt update

echo '----------download K8S-------------------------------------------------------'
sudo apt-get install kubelet -y
sudo apt-get  install kubeadm -y
sudo systemctl start kubelet
sudo systemctl enable kubelet
sudo apt-get install containerd -y
echo '----------download and start/daemon  K8S done-------------------------------'



echo '----------configure config.toml-----------------------------------------------'
sudo echo '
plugins."io.containerd.grpc.v1.cri".containerd]
  SystemdCgroup = true
  snapshotter = "overlayfs"
' > /etc/containerd/config.toml
echo '----------configure done------------------------------------------------------'

echo '----------config crictl.yaml--------------------------------------------------'
sudo echo ' 
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
' > /etc/crictl.yaml
echo '----------configure done------------------------------------------------------'


echo '----------chown/chmod---------------------------------------------------------'
sudo chown root:root /var/run/containerd/
sudo chmod -R 755 /var/run/containerd/
echo '----------chown/chmod done----------------------------------------------------'


sudo systemctl restart  containerd 
sudo systemctl enable containerd

sudo apt-mark hold containerd kubelet kubeadm kubectl
