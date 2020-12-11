#!/bin/bash

# define an initial config with password for Rasa X set to 'workshop'
cat <<EOF > values.yml
# debugMode enables / disables the debug mode for Rasa and Rasa X
debugMode: true
nginx:
  service:
    # connect LoadBalancer directly to VMs' internal IP
    # You get this value with: $ hostname -I
    externalIPs: [$INTERNAL_IP]
rasax:
    # initialUser is the user which is created upon the initial start of Rasa X
    initialUser:
        # password for the Rasa X user
        password: "workshop"
    # passwordSalt Rasa X uses to salt the user passwords
    passwordSalt: "`openssl rand -hex 12`"
    # token Rasa X accepts as authentication token from other Rasa services
    token: "`openssl rand -hex 12`"
    # jwtSecret which is used to sign the jwtTokens of the users
    jwtSecret: "`openssl rand -hex 12`"
    # tag refers to the Rasa X image tag
    tag: "0.33.0"
rasa:
    # token Rasa accepts as authentication token from other Rasa services
    token: "`openssl rand -hex 12`"
    # tag refers to the Rasa image tag
    tag: "2.0.3-full"
rabbitmq:
    # rabbitmq settings of the subchart
    rabbitmq:
        # password which is used for the authentication
        password: "`openssl rand -hex 12`"
global:
    # postgresql: global settings of the postgresql subchart
    postgresql:
        # postgresqlPassword is the password which is used when the postgresqlUsername equals "postgres"
        postgresqlPassword: "`openssl rand -hex 12`"
    # redis: global settings of the postgresql subchart
    redis:
        # password to use in case there no external secret was provided
        password: "`openssl rand -hex 12`"
EOF

# reinstall the rasa-x
kubectl delete namespace $NS
kubectl create namespace $NS
helm repo add rasa-x https://rasahq.github.io/rasa-x-helm
helm --namespace $NS install --values values.yml $RELEASE_NAME rasa-x/rasa-x

# monitor installation with
# k get deployments

# verify installation is successful
echo "Visit endpoint at http://$PUBLIC_IP:8000/api/version"
echo "Log in with the predefined Rasa X password at http://$PUBLIC_IP:8000"