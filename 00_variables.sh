#!/bin/bash

# namespace name
NS="demo-deploy-rasa"

# release name
RELEASE_NAME="dummy-release"

# get the machine's internal ip address
INTERNAL_IP=`echo $(hostname -I) | cut -f 1 -d ' '`

# get the machine's public address
PUBLIC_IP=`curl ipinfo.io | jq '.ip' | tr -d \"`

