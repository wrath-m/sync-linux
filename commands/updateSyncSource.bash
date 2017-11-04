#!/bin/bash

cd $HOME/syncCore
ssh-add ./id_rsa && git checkout -- . && git pull

# create sync folder
mkdir -p $HOME/sync/portable

# autostart
mkdir -p $HOME/.config/autostart
cp -a $HOME/syncCore/autostart/. $HOME/.config/autostart

# user commands
mkdir -p $HOME/bin
cp -a $HOME/syncCore/userCommands/. $HOME/bin
chmod -R 755 $HOME/bin

# shortcuts
mkdir -p $HOME/.local/share/applications
if [[ ! -f $HOME/.local/share/applications/sublime_text.desktop ]]; then
    cp $HOME/syncCore/portable/sublime_text_3/sublime_text.desktop $HOME/.local/share/applications/sublime_text.desktop
    sed -i "s#REPLACE_WITH_HOME#$HOME#g" $HOME/.local/share/applications/sublime_text.desktop
    sed -i "s#REPLACE_WITH_ICON#$HOME/sync/portable/sublime_text_3/Icon/256x256/sublime-text.png#g" $HOME/.local/share/applications/sublime_text.desktop
fi

# bash config
if [[ ! -f $HOME/.bashrc ]]; then
    touch $HOME/.bashrc
fi
cp $HOME/syncCore/portable/bashConfig $HOME/sync/portable/bashConfig
if !(grep -Fq '. ./sync/portable/bashConfig' $HOME/.bashrc); then
    echo -e '\n#SyncCore\nif [[ -f ./sync/portable/bashConfig ]]; then\n\t. ./sync/portable/bashConfig\nfi' >> $HOME/.bashrc
fi

# vim options
if [[ ! -f $HOME/.vimrc ]]; then
    touch $HOME/.vimrc
fi
if !(grep -Fq 'set number' $HOME/.vimrc); then
    echo -e '\nset number' >> $HOME/.vimrc
fi

# sublime
mkdir -p $HOME/.config/sublime-text-3
rsync -av --delete $HOME/syncCore/portable/* $HOME/sync/portable
rsync -av --exclude="Packages/User/Package Control.cache*" --exclude="Packages/User/Package Control.ca-certs*" --exclude="Packages/User/Package Control.last-run" --exclude="Packages/User/Package Control.ca-list" --exclude="Packages/User/Package Control.ca-bundle" --exclude="Packages/User/Package Control.system-ca-bundle" $HOME/syncCore/portable/sublime_text_3/.config/. $HOME/.config/sublime-text-3
