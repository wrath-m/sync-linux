#!/bin/bash

dir="$(dirname "$0")"
. "$dir/../docker.config"

sudo docker rmi "$dockerImageName"
sudo docker rmi $(sudo docker images -f dangling=true -q) > /dev/null 2>&1
