cd $HOME/syncCore
git add --all
git commit -m 'update source'
ssh-add ./id_rsa && git push
