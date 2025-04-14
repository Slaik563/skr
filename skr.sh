#!/bin/bash

# Exit on error, undefined variable, or error in any pipeline
set -euxo pipefail

# Variables
KUBERNETES_VERSION="1.28.1-00"
OS="xUbuntu_22.04"
VERSION="1.28"

# Disable swap and keep it off during reboot
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# Update package list
sudo apt-get update -y

# Install CRI-O Runtime
# Load required modules and set sysctl params
echo -e "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/crio.conf
sudo modprobe overlay
sudo modprobe br_netfilter

echo -e "net.bridge.bridge-nf-call-iptables=1\nnet.ipv4.ip_forward=1\nnet.bridge.bridge-nf-call-ip6tables=1" | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
sudo sysctl --system

# Add CRI-O to sources and install
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -

sudo apt-get update
sudo apt-get install -y cri-o cri-o-runc

sudo systemctl daemon-reload
sudo systemctl enable crio --now

echo "CRI runtime installed successfully"

# Install Kubernetes components
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION"

# Install jq and set Kubelet node IP
sudo apt-get install -y jq
local_ip=$(ip --json addr show eth0 | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')
echo "KUBELET_EXTRA_ARGS=--node-ip=$local_ip" | sudo tee /etc/default/kubelet > /dev/null