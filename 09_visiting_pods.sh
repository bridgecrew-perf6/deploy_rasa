#!/bin/bash

# to look at what's inside the rasa-x pod
podname=`k get pods -o custom-columns=NAME:.metadata.name | grep rasa-x`

# execute a command on the first container in a pod
k exec $podname -- ls -la
k exec $podname -- uname -a

# to open a shell in the first container in a pod
k exec --stdin --tty $podname -- bash

# list persistent storage in the cluster
k get pvc

# list non-persistent storage
k get configmap