pkill -f "syncSourceProcess.bash"
sleep 0.5
gnome-terminal -e 'bash -c "bash $HOME/syncCore/commands/syncSourceProcess.bash"'
