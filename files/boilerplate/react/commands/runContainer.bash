#!/bin/bash

dir="$(dirname "$0")"
. "$dir/../docker.config"
srcFolder="$(realpath "$dir/../src")"

echo 'container name:'
read containerName
runCommand="sudo docker run -v "$srcFolder:/usr/src" -dit --name "$containerName""
if [[ "$dockerExposePort" ]]; then
    runCommand="$runCommand -p $dockerExposePort"
else
    echo 'n'
fi
runCommand="$runCommand "$dockerImageName""
$runCommand
