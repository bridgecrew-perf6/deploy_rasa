#!/bin/bash

# this script shows how to connect Rasa X to a github repo containing a bot
# and view the model training and serving logs

# get the access token for the user we created in 08_set_login_credentials.sh
ACCESS_TOKEN=`curl -X POST -H "Content-Type: application/json" \
                  -d '{"username": "me", "password": "workshop" }' \
                  http://$PUBLIC_IP:8000/api/auth | \
             jq ".access_token" | \
             tr -d \" `

# generate a new, single-use SSH key
ssh-keygen -t rsa -b 4096 -f git-deploy-key -q -N ""
SSH_PRIVATE_KEY=`cat git-deploy-key`

# fork  https://github.com/hsm207/deployment-workshop-bot-1 and get the SSH url
# of this forked repo
REPO_URL="git@github.com:hsm207/deployment-workshop-bot-1.git"

# define a repository.json file
cat <<EOF > repository.json
{
    "repository_url": "$REPO_URL",
    "target_branch": "master",
    "ssh_key": "$SSH_PRIVATE_KEY",
    "is_target_branch_protected": true
}
EOF

# add git-deploy-key.pub as a deploy key to the REPO_URL
# see here for more details: https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys
# make sure to allow write access!

# Now we can create the repo in Rasa X!
curl --request POST \
     --url http://$PUBLIC_IP:8000/api/projects/default/git_repositories \
     --header "Authorization: Bearer $ACCESS_TOKEN" \
     --header 'Content-Type: application/json' \
     --data-binary @repository.json

# fyi, Rasa X maintains a sync copy of the repo in the /app/git directory
# e.g. to view the requirements.txt file stored in Rasa X:
k exec `k get pods -o custom-columns=NAME:.metadata.name | grep rasa-x` -- cat /app/git/1/requirements.txt

# model training is done by the rasa-worker pods
# before training the model using the Rasa X UI, view the logs
k logs `k get pods -o custom-columns=NAME:.metadata.name | grep rasa-worker` --follow
# to train the model in Rasa X:
# Training -> Add model -> Train model
# and notice the traininig progress in the logs of the rasa-worker pod

# model serving is done by the rasa-production pods
# before marking a model as active using the Rasa X UI, view the logs
k logs `k get pods -o custom-columns=NAME:.metadata.name | grep rasa-production` --follow
# to make a model active using Rasa X:
#  Models -> select a model -> Make model active
# and notice that rasa-production pod is retrieving the model, unzipping it, etc

# now we can talk to the bot in Rasa X! Just go to:
# Talk to your bot
