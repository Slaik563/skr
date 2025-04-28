#!/bin/bash

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
suod ufw allow 2379/tcp
echo '----------opening ports done-------------------------------------------------'

sudo apt update

echo '----------download K8S-------------------------------------------------------'
sudo apt-get  install  kubectl kubelet kubeadm containerd -y  
sudo systemctl start kubelet
sudo systemctl enable kubelet
echo '----------download and start/daemon  K8S done-------------------------------'


echo '----------configure config.toml-----------------------------------------------'
echo '
 
# Включение CRI плагина
 [plugins."io.containerd.grpc.v1.cri"]
   # Настройка образов (опционально)
   sandbox_image = "registry.k8s.io/pause:3.10"  # Образ для sandbox контейнеров

   # Настройка дополнительных параметров CRI (по желанию)
   [plugins."io.containerd.grpc.v1.cri".containerd]
     default_runtime_name = "runc"  # Используемый runtime
     [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
       runtime_type = "io.containerd.runc.v2"
       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
         SystemdCgroup = true  # Включение драйвера cgroups

  # Настройка логирования (опционально)
   [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
     snapshotter = "overlayfs"  # Драйвер для слоев контейнеров
     disable_snapshot_annotations = true

 # Отключение неиспользуемых плагинов (опционально)
 disabled_plugins = ["cri-containerd"]  # Отключение старого CRI плагина (если он есть)

 # Настройка общих параметров containerd
 version = 2  # Версия конфигурации
 root = "/var/lib/containerd"  # Корневая директория для данных containerd
 state = "/run/containerd"  # Директория для состояния containerd
 oom_score = 0  # Приоритет OOM killer

 # Настройка логирования (опционально)
 [debug]
   level = "info"  # Уровень логирования (info, debug, warn, error)

 # Настройка garbage collection (опционально)
 [gctrace]
   interval = "1h"  # Интервал сборки мусора
' > sudo tee  /etc/containerd/config.toml
echo '----------configure done------------------------------------------------------'


echo '----------chown/chmod---------------------------------------------------------'
sudo chown root:root /var/run/containerd/
sudo chmod -R 755 /var/run/containerd/
echo '----------chown/chmod done----------------------------------------------------'
sudo systemctl restart containerd 
sudo systemctl enable containerd 

echo '----------config crictl.yaml--------------------------------------------------'
echo ' 
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
' > sudo tee /etc/crictl.yaml
echo '----------configure done------------------------------------------------------'

sudo chmod 644 /etc/crictl.yaml
sudo chown root:root /etc/crictl.yaml



sudo apt-mark hold containerd kubelet kubeadm kubectl 
