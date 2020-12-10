#!/bin/bash

kubectl create namespace $NS

helm repo add rasa-x https://rasahq.github.io/rasa-x-helm
helm --namespace $NS install $RELEASE_NAME rasa-x/rasa-x

# check status of deployment with:
#  k get deployments
# or browse octant