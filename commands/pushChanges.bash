cd $HOME/syncCore
ssh-add ./id_rsa
git add --all autostart
git add --all portable
git add --all files
git commit -m 'update'
git push
