#!/bin/bash


#echo "install and configure haproxy"
#sudo apt install haproxy -y
#sudo systemctl start haproxy
#sudo systemctl enable haproxy
#
#cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
#global
#    log /dev/log local0
#    log /dev/log local1 notice
#    chroot /var/lib/haproxy
#    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
#    stats timeout 30s
#    user haproxy
#    group haproxy
#    daemon
#
#defaults
#    log global
#    mode tcp
#    option tcplog
#    timeout connect 5000ms
#    timeout client 50000ms
#    timeout server 50000ms
#
#frontend kubernetes_api_frontend
#    bind 0.0.0.0:6443
#    mode tcp
#    default_backend kubernetes_api_backend
#
#backend kubernetes_api_backend
#    mode tcp
#    balance roundrobin
#    option tcp-check
#    server kube-server1 10.0.2.12:6443 check
#    server kube-server2 10.0.2.13:6443 check
#EOF

#sudo systemctl restart haproxy

#sudo systemctl start kubelet  

#echo "10.0.2.12 loadbalancer" | sudo tee -a /etc/hosts

sudo swapoff -a

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

echo "----------Start kubedm init---------------------------------------------------------------"
sudo kubeadm init --control-plane-endpoint "10.0.2.19:6443" --upload-certs --pod-network-cidr=192.168.0.0/16  | sudo tee /home/serv2/log_init.log
echo "----------recored /home/serv2/log_init.log------------------------------------------------"


sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g)  $HOME/.kube/config
echo "done"

echo "--------------------Cpy Tocken-----------------------------------"
echo "--------------------Cpy Tocken-----------------------------------"
echo "--------------------Cpy Tocken-----------------------------------"

