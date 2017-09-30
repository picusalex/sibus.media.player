#!/usr/bin/env bash

SERVICE="sibus.mediaplayer"

INSTALL_DIR=`pwd`
SERVICE_PATH="$INSTALL_DIR/sibus.media.player.py"
SYSTEMD_SERVICE="$SERVICE.service"
SYSTEMD_ORG="$INSTALL_DIR/systemd-config"
SYSTEMD_TMP="$INSTALL_DIR/$SYSTEMD_SERVICE"
SYSTEMD_DST="/lib/systemd/system/$SYSTEMD_SERVICE"

echo " # Update folder from git repository"
git fetch origin master
git reset --hard origin/master

if [ ! -e $SERVICE_PATH ]; then
    echo " !!! ERROR: file $SERVICE_PATH not found !!!"
    echo " (script must be run from its own directory !)"
    exit 1
fi
sudo chmod +x $SERVICE_PATH

echo " # Checking service $SERVICE dependencies"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mplayer | grep "install ok installed")
if [ "" == "$PKG_OK" ]; then
  echo "Installing mplayer"
  sudo apt-get update
  sudo apt-get --force-yes --yes install mplayer
fi

sudo pip install --upgrade sibus_lib

echo " # Patching service $SERVICE systemd config file..."
sed 's|<SCRIPT_PATH>|'$SERVICE_PATH'|g' $SYSTEMD_ORG > "/tmp/tmp.systemd"
sed 's|<USER>|'$USER'|g' "/tmp/tmp.systemd" > $SYSTEMD_TMP
echo " = systemd config: "
cat $SYSTEMD_TMP

echo " # Installing service $SERVICE"
sudo cp -fv $SYSTEMD_TMP $SYSTEMD_DST
sudo systemctl daemon-reload

echo " # Enable & start service $SERVICE at boot"
sudo systemctl enable $SYSTEMD_SERVICE
sudo systemctl start $SYSTEMD_SERVICE

echo " # Service $SERVICE status"
sudo systemctl status $SYSTEMD_SERVICE
exit 0


#### AUDIO BT INSTALL ############################################

pulseaudio --start
sleep 2
echo -e "connect 08:DF:1F:8D:2B:C6 \nquit" | /usr/bin/bluetoothctl
sleep 8
pacmd set-default-sink bluez_sink.08_DF_1F_8D_2B_C6
sleep3
/etc/init.d/sibus.media.player.service restart