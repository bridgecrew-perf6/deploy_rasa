#!/bin/bash

# let's scale the pods in the rasa-production deployment to 2
# before (Ready: 1/1, Available: 1)
k get deployments

# scale up
k scale deployment $RELEASE_NAME-rasa-production --replicas=2

# after (Ready: 2/2, Available: 1)
k get deployments

# scale down
k scale deployment $RELEASE_NAME-rasa-production --replicas=1
k get deployments

# Tip: you can force a pod restart, by scaling the deployment down to 0
# and then back up to 1

# you can also scale using config file when installing/upgrading
# e.g. upgrading:
# scale to 10 pods
cat <<EOF > values.yml
# rasa: Settings common for all Rasa containers
rasa:
    versions:
       # rasaProduction is the container which serves the production environment
       rasaProduction:
           # replicaCount of the Rasa Production container
           replicaCount: 10
EOF

helm --namespace $NS upgrade --values values.yml $RELEASE_NAME rasa-x/rasa-x

# scale down to 1
cat <<EOF > values.yml
# rasa: Settings common for all Rasa containers
rasa:
    versions:
       # rasaProduction is the container which serves the production environment
       rasaProduction:
           # replicaCount of the Rasa Production container
           replicaCount: 1
EOF
helm --namespace $NS upgrade --values values.yml $RELEASE_NAME rasa-x/rasa-x
