#!/bin/bash

# apt install
apt-get update
apt-get upgrade -y
apt-get install software-properties-common -y
add-apt-repository ppa:nginx/stable -y
apt-get install wget -y
apt-get install nano -y
apt-get install vim -y

# bash config
if [[ ! -f /root/.bashrc ]]; then
    touch /root/.bashrc
fi
echo -e '. /root/bashConfig\n' >> /root/.bashrc

# vim options
if [[ ! -f /root/.vimrc ]]; then
    touch /root/.vimrc
fi
# set number example
# if !(grep -Fq 'set number' .vimrc); then
    # echo -e '\nset number' >> .vimrc
# fi
