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
command -v pico2wave >/dev/null 2>&1 || {
    echo >&2 "Installing picoTTS";
    sudo apt-get update;
    sudo apt-get --force-yes --yes install picostts;
    }

sudo pip install --upgrade sibus_lib || { echo "Error during sibus_lib installation"; exit 1; }

echo " # Patching service $SERVICE systemd config file..."
sed 's|<SCRIPT_PATH>|'$SERVICE_PATH'|g' $SYSTEMD_ORG > "/tmp/tmp.systemd"
sed 's|<SCRIPT_DIR>|'$INSTALL_DIR'|g' "/tmp/tmp.systemd" > "/tmp/tmp2.systemd"
sed 's|<USER>|'$USER'|g' "/tmp/tmp2.systemd" > $SYSTEMD_TMP
echo " = systemd config: "
cat $SYSTEMD_TMP

echo " # Installing service $SERVICE"
sudo cp -fv $SYSTEMD_TMP $SYSTEMD_DST
sudo systemctl daemon-reload || { echo "Error during systemctl daemon-reload"; exit 1; }

echo " # Enable & start service $SERVICE at boot"
sudo systemctl enable $SYSTEMD_SERVICE || { echo "Error during systemctl enable"; exit 1; }
sudo systemctl start $SYSTEMD_SERVICE || { echo "Error during systemctl start"; exit 1; }

echo " # Service $SERVICE status"
sudo systemctl status $SYSTEMD_SERVICE || { echo "Error during systemctl status"; exit 1; }

exit 0
