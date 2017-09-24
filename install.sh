#!/usr/bin/env bash


sudo apt-get update
sudo apt-get install mplayer

pip install sibus_lib

SERVICE="sibus.media.player.service"

SERVICE_ORG="./$SERVICE"
SERVICE_DST="/etc/init.d/$SERVICE"

if [ ! -e $SERVICE_ORG ]; then
    echo "ERROR: file $SERVICE_ORG not found !"
    exit 1
fi

echo "Installing service $SERVICE"
chmod 0755 $SERVICE_ORG
if [ -e SERVICE_DST ]; then
    sudo unlink $SERVICE_DST
fi
sudo ln -s -v $SERVICE_ORG $SERVICE_DST

echo "Enable service $SERVICE at boot"
sudo update-rc.d $SERVICE defaults

exit 0