#!/bin/bash

# we have another bot that comes with a custom action
# so let's start over from scratch
kubectl delete namespace $NS
kubectl create namespace $NS
helm repo add rasa-x https://rasahq.github.io/rasa-x-helm

# the repo we are interested in is https://github.com/hsm207/deployment-workshop-bot-2.git
REPO_URL_HTTPS="https://github.com/hsm207/deployment-workshop-bot-2.git"
REPO_URL_SSH="git@github.com:hsm207/deployment-workshop-bot-2.git"

# to get the action server running, we need to containerized the action and be
# able to pull it as part of installing Rasa X

# microk8s has a built-in container registry
# so we can build an image of the action server and push it to this
# container registry

git clone $REPO_URL_HTTPS
pushd deployment-workshop-bot-2
docker-compose build
docker push localhost:32000/deployment-workshop-bot-2-action-server:0.0.1
popd

# now we need to update our config to setup the action server
# the action server is called app
cat <<EOF > values.yml
# debugMode enables / disables the debug mode for Rasa and Rasa X
debugMode: true
# custom action server
app:
    # from microk8s build-in registry
    name: "localhost:32000/deployment-workshop-bot-2-action-server"
    tag: "0.0.1"
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

# install the config
helm --namespace $NS install --values values.yml $RELEASE_NAME rasa-x/rasa-x

# now we need to train the model

# similar to before, we fork the target repo and get the 
# SSH url of this forked repo
# follow the same steps as before to train the bot on Rasa X
# remember to add the deploy key to the repo!

# remove previous deploy keys because keys must be unique
# to each repo
rm git-deploy-key*
ssh-keygen -t rsa -b 4096 -f git-deploy-key -q -N ""
SSH_PRIVATE_KEY=`cat git-deploy-key`

# the access token to authenticate to Rasa X
ACCESS_TOKEN=`curl -X POST -H "Content-Type: application/json" \
                  -d '{"username": "me", "password": "workshop" }' \
                  http://$PUBLIC_IP:8000/api/auth | \
             jq ".access_token" | \
             tr -d \" `

cat <<EOF > repository.json
{
    "repository_url": "$REPO_URL_SSH",
    "target_branch": "master",
    "ssh_key": "$SSH_PRIVATE_KEY",
    "is_target_branch_protected": true
}
EOF

curl --request POST \
     --url http://$PUBLIC_IP:8000/api/projects/default/git_repositories \
     --header "Authorization: Bearer $ACCESS_TOKEN" \
     --header 'Content-Type: application/json' \
     --data-binary @repository.json

# train the bot using Rasa X and mark the model as active

# now we verify that the rasa-production pod can communicate with the custom action server
# the app deployment has a service named RELEASE_NAME-rasa-x-app (you can figure out the name by looking at the deployment's Resource Viewer in Octant)
# so from inside the rasa-production pod, we need to verify we can reach this service at port 5055 (the default port to listen for actions)
k exec `k get pods -o custom-columns=NAME:.metadata.name | grep rasa-production` -- curl -s http://$RELEASE_NAME-rasa-x-app:5055/health

# to check for actions that have been registered
k exec `k get pods -o custom-columns=NAME:.metadata.name | grep rasa-production` -- curl -s http://$RELEASE_NAME-rasa-x-app:5055/actions

# just for fun, we can also check that the rasa-production pod can reach the rasa-x pod
k exec `k get pods -o custom-columns=NAME:.metadata.name | grep rasa-production` -- curl -s http://$RELEASE_NAME-rasa-x-rasa-x:5002/api/version

# now you are ready to talk to the bot in Rasa X!