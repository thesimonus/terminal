#!/bin/sh

# install Docker on Ubuntu 22.04
sudo apt update
sudo apt upgrade
sudo apt install docker.io

# install Docker Compose on Ubuntu 22.04
# sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose

sudo apt update 
sudo apt install docker-compose -y
