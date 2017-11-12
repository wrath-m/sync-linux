#!/bin/bash

pkill -f "syncSourceProcess.bash"
sleep 0.5

echo 'git repository url?'
read gitUrl

echo 'path to git private ssh key?'
read sshKeyPath
sshKeyPath=$(eval echo "$sshKeyPath")

if [[ ! -f $sshKeyPath ]]; then
    echo 'file does not exist'
    echo 'exiting'
    exit 1
fi

# install linux packages
if (command -v apt >/dev/null 2>&1); then
    packageManager='apt'
else
    packageManager='apt-get'
fi
if !(command -v git >/dev/null 2>&1); then
    sudo $packageManager install -y git
fi
if !(command -v gnome-terminal >/dev/null 2>&1); then
    sudo $packageManager install -y gnome-terminal
fi
if !(command -v inotifywait >/dev/null 2>&1); then
    sudo $packageManager install -y inotify-tools
fi
if !(command -v guake >/dev/null 2>&1); then
    sudo $packageManager install -y guake
    guake > /dev/null 2>&1 & disown
fi
if !(command -v add-apt-repository > /dev/null 2>&1); then
    sudo $packageManager install -y software-properties-common
fi
if !(command -v curl > /dev/null 2>&1); then
    sudo $packageManager install -y curl
fi
if !(command -v wget > /dev/null 2>&1); then
    sudo $packageManager install -y wget
fi
if !(command -v nano > /dev/null 2>&1); then
    sudo $packageManager install -y nano
fi
if !(command -v vim > /dev/null 2>&1); then
    sudo $packageManager install -y vim
fi

if !(command -v docker > /dev/null 2>&1); then
    sudo $packageManager install -y docker.io
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl restart docker
fi

if !(command -v docker-machine > /dev/null 2>&1); then
    curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
    chmod +x /tmp/docker-machine &&
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
fi

rm -rf $HOME/sync
rm -rf $HOME/syncCore
mkdir $HOME/syncCore

cp "$sshKeyPath" "/tmp/syncCoreIdRsa"
chmod 700 "/tmp/syncCoreIdRsa"
ssh-add "/tmp/syncCoreIdRsa"
git clone "$gitUrl" $HOME/syncCore/.
mv "/tmp/syncCoreIdRsa" "$HOME/syncCore/id_rsa"

# install programs
if !(command -v google-chrome-stable); then
    sudo dpkg -i chrome.deb
    sudo apt install -f
fi
if !(command -v virtualbox); then
    sudo dpkg -i virtualbox.deb
    sudo apt install -f
fi

pkill -f "runSyncSourceProcess.bash"
gnome-terminal -e 'bash -c "bash $HOME/syncCore/commands/runSyncSourceProcess.bash"'

# Detect OS example

# if [ -f /etc/os-release ]; then
#     # freedesktop.org and systemd
#     . /etc/os-release
#     OS=$NAME
#     VER=$VERSION_ID
# elif type lsb_release >/dev/null 2>&1; then
#     # linuxbase.org
#     OS=$(lsb_release -si)
#     VER=$(lsb_release -sr)
# elif [ -f /etc/lsb-release ]; then
#     # For some versions of Debian/Ubuntu without lsb_release command
#     . /etc/lsb-release
#     OS=$DISTRIB_ID
#     VER=$DISTRIB_RELEASE
# elif [ -f /etc/debian_version ]; then
#     # Older Debian/Ubuntu/etc.
#     OS=Debian
#     VER=$(cat /etc/debian_version)
# elif [ -f /etc/SuSe-release ]; then
#     # Older SuSE/etc.
#     OS=SuSE
# elif [ -f /etc/redhat-release ]; then
#     # Older Red Hat, CentOS, etc.
#     OS=RedHat
# else
#     # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
#     OS=$(uname -s)
#     VER=$(uname -r)
# fi
# OS=${OS,,}

# if !(command -v git >/dev/null 2>&1); then
#   if [[ $OS == *'ubuntu' || $OS == *'debian'* ]]; then
#       if (command -v apt >/dev/null 2>&1); then
#           sudo apt install -y git
#       else
#           sudo apt-get install -y git
#       fi
#   elif [[ $OS == *'centos'* || $OS == *'fedora'* || $OS == *'redhat'* || $OS == *'red hat'* ]]; then
#       sudo yum install -y git
#   fi
# fi

# if !(command -v inotifywait >/dev/null 2>&1); then
#   if [[ $OS == *'ubuntu' || $OS == *'debian'* ]]; then
#       if (command -v apt >/dev/null 2>&1); then
#           sudo apt install -y inotify-tools
#       else
#           sudo apt-get install -y inotify-tools
#       fi
#   elif [[ $OS == *'centos'* || $OS == *'fedora'* || $OS == *'redhat'* || $OS == *'red hat'* ]]; then
#       sudo yum install -y inotify-tools
#    fi
# fi
