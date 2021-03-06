#!/bin/bash

dir="$(dirname "$0")"
. "$dir/../docker.config"

echo 'container name:'
read containerName

if [[ $(sudo docker ps -a | grep -w "$containerName" | grep -w "$dockerImageName") ]]; then
    sudo docker exec -it "$containerName" bash
else
    echo 'there is no container with this name using the required image'
fi
