#!/bin/bash

dir="$(dirname "$0")"
. "$dir/../docker.config"
rootFolder="$(realpath "$dir/../")"

cp "$rootFolder/Dockerfile.template" "$rootFolder/Dockerfile"
sed -i "s#<<REPLACE_WITH_DOCKER_IMAGE_FROM>>#$dockerImageFrom#g" "$rootFolder/Dockerfile"
sudo docker build --rm -t "$dockerImageName" "$rootFolder/."
sudo docker rmi $(sudo docker images -f dangling=true -q) > /dev/null 2>&1
rm "$rootFolder/Dockerfile"
