#!/bin/bash
sudo apt-get update && apt-get install -y ca-certificates git-core ssh golang git vim build-essential net-tools
echo "export GOPATH=$HOME/go" >> ~/.bashrc && source ~/.bashrc

# Install SwaggerGo
sudo apt install gnupg ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61
echo "deb https://dl.bintray.com/go-swagger/goswagger-debian ubuntu main" | sudo tee /etc/apt/sources.list.d/goswagger.list
sudo apt update && sudo apt install swagger

# Clone Skymind for latest Documentation
git clone -b websocket/refactor https://github.com/shifty21/skymind.git
cd skymind/ && swagger generate spec -o ./swaggerui/swagger.json --scan-models --include=./services/ --exclude=./

# Install widdershins
sudo apt install npm && sudo npm install -g widdershins
widdershins --search false --language_tabs 'go:Go' 'python:Python' --expandBody true --verbose true --summary swaggerui/swagger.json -o docs/apidoc.md

# Install docker and setup non root access
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install uidmap
dockerd-rootless-setuptool.sh install
echo "export PATH=/usr/bin:$PATH" >> .bashrc
echo "export DOCKER_HOST=unix:///run/user/1001/docker.sock" >> .bashrc

# Build the documentation.
docker run --rm --name slate -p 4567:4567 -v $(pwd)/build:/srv/slate/build -v "$(pwd)/docs/apidoc.md":"/srv/slate/source/index.html.md" slatedocs/slate

# Serve the documentation using nginx
cd build/ && sudo apt install nginx && sudo mkdir -p /var/www/skyapi
sudo cp -r * /var/www/skyapi/

# add the  nginx config file.
nano /etc/nginx/sites-enabled/skyapi

sudo ln -s /etc/nginx/sites-available/skyapi /etc/nginx/sites-enabled/skyapi

# Install the Lets encrpyt certificate system.
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Generate and setup the SSL certificate automatically.
sudo certbot --nginx
