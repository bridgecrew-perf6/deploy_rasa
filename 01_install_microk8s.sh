#!/bin/bash

sudo apt update

sudo apt install -y docker.io \
    docker-compose \
    snap

sudo snap install microk8s --classic

