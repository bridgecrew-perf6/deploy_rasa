#!/bin/bash

# namespace name
NS="demo-deploy-rasa"

# release name
RELEASE_NAME="dummy-release"

# get the machine's internal ip address
INTERNAL_IP=`echo $(hostname -I) | cut -f 1 -d ' '`

# get the machine's public address
PUBLIC_IP=`curl ipinfo.io | jq '.ip' | tr -d \"`

# unmask the docker service and start it
# see: https://bit.ly/3nnBkBf
sudo systemctl unmask docker.service
sudo systemctl unmask docker.socket
sudo systemctl start docker.service
sudo systemctl status docker