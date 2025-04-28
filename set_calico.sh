#!/bin/bash

echo "----------calico start load/ set calico-----------------------------------------------" 

cd /home/serv*/
sudo curl https://docs.projectcalico.org/manifests/calico.yaml -O

sudo kubectl apply -f calico.yaml

echo "----------calico load/set done--------------------------------------------------------"


echo"-----------apply calico----------------------------------------------------------------"
sudo kubectl apply -f /home/serv*/calico.yaml
echo"-----------done------------------------------------------------------------------------"
