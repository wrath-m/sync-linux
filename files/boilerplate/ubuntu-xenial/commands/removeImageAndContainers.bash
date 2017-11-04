#!/bin/bash

dir="$(dirname "$0")"
. "$dir/../docker.config"

sudo docker ps -a | awk '{ print $1,$2 }' | grep "$dockerImageName" | awk '{print $1 }' | xargs -I {} sudo docker rm -f {}
sudo docker rmi "$dockerImageName"
sudo docker rmi $(sudo docker images -f dangling=true -q) > /dev/null 2>&1
