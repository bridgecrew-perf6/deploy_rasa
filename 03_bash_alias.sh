#!/bin/bash

echo alias kubectl=\'microk8s.kubectl\' >> $HOME/.bashrc
echo alias helm=\'microk8s.helm3\' >> $HOME/.bashrc

# aliases for namespace
echo alias k=\"kubectl --namespace $NS\" >> $HOME/.bashrc
echo alias h=\"helm --namespace $NS\" >> $HOME/.bashrc

source $HOME/.bashrc
