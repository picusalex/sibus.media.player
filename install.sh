#!/usr/bin/env bash

SERVICE="sibus-mediaplayer"

INSTALL_DIR=`pwd`
SERVICE_ORG="$INSTALL_DIR/sibus.media.player.service"
SERVICE_DST="/etc/init.d/$SERVICE"

if [ ! -e $SERVICE_ORG ]; then
    echo "ERROR: file $SERVICE_ORG not found !"
    exit 1
fi

echo "Checking service $SERVICE dependencies"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mplayer | grep "install ok installed")
if [ "" == "$PKG_OK" ]; then
  echo "Installing mplayer"
  sudo apt-get update
  sudo apt-get --force-yes --yes install mplayer
fi

sudo pip install --no-cache-dir sibus_lib

echo "Patching service $SERVICE"
sed -i 's|<INSTALL_DIR>|'$INSTALL_DIR'|g' $SERVICE_ORG

echo "Installing service $SERVICE"
chmod 0755 $SERVICE_ORG
if [ -e $SERVICE_DST ]; then
    sudo unlink $SERVICE_DST
fi
sudo ln -s -v $SERVICE_ORG $SERVICE_DST

echo "Enable service $SERVICE at boot"
sudo systemctl enable $SERVICE

exit 0


#### AUDIO BT INSTALL ############################################

pulseaudio --start
sleep 2
echo -e "connect 08:DF:1F:8D:2B:C6 \nquit" | /usr/bin/bluetoothctl
sleep 8
pacmd set-default-sink bluez_sink.08_DF_1F_8D_2B_C6
sleep3
/etc/init.d/sibus.media.player.service restart