#!/bin/bash

# allow the VM's public ip address to connect to the rasa-x-nginx (k8s service: LoadBalancer)
# i.e. give an external ip to the rasa-x-nginx load balancer

# before (external ip is pending):
k get services $RELEASE_NAME-rasa-x-nginx

# allow the LoadBalancer to connet to the machine's internal IP
cat <<EOF > values.yml
nginx:
    service:
        externalIPs: [$INTERNAL_IP]
EOF

helm --namespace $NS upgrade --values values.yml $RELEASE_NAME rasa-x/rasa-x

# check that rasa-x-nginx has the correct external ip
echo "Machine's internal ip: $INTERNAL_IP"
k get services $RELEASE_NAME-rasa-x-nginx

# check that the endpoint is accessible from within the machine
curl http://$INTERNAL_IP:8000/api/version

# check endpoint is accessible over the internet
echo "Open a web browser and go to http://$PUBLIC_IP:8000/api/version"