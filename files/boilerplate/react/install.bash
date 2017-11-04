#!/bin/bash

apt-get install nginx -y
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
. .nvm/nvm.sh
nvm install 8.9.0
nvm alias default 8.9.0