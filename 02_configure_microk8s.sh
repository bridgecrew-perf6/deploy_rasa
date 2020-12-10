#!/bin/bash

# join microk8s group
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# add /snap/bin to PATH
echo export PATH="/snap/bin:$PATH" >> $HOME/.bashrc
source ~/.bashrc

# add ons
microk8s enable dns storage helm3 registry dashboard ingress

# config kubectl
microk8s config > $HOME/.kube/config
