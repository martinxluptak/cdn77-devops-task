#!/bin/bash

# update package index
sudo apt-get update

# install python3
sudo apt-get install -y python3 python3-pip python3-virtualenv

# create and enable virtualenv
python3 -m venv env
source env/bin/activate

# install ansible
pip3 install ansible

# install tools for adding docker apt repository
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# add docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# set up docker apt repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update apt index and install docker, docker-compose
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# test docker installation
sudo docker run hello-world


# add user to docker group, login again
usermod -a -G docker $USER
sudo su $USER
