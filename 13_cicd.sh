#!/bin/bash

# The repo https://github.com/hsm207/deployment-workshop-bot-2.git
# has a CICD pipeline (see /.github/workflows/ci_on_push.yml) that
# will train and test this model on push

# The way to make use of this pipeline is to first annotate some data in Rasa X.
# Then, in Rasa X, click "Add changes to Git server". This will push the changes
# to github in a separate branch and trigger the workflow defined in
# ci_on_push.yml

# Let the repo in Rasa X sync with the master branch on GitHub and then retrain the
# model

# To see what else is possible, refer to:
# * https://github.com/RasaHQ/rasa-demo/blob/9984e588e6d85a24bad87860ed808b73a8cc2523/.github/workflows/build_and_deploy.yml
# * https://github.com/marketplace/actions/build-action-server-image