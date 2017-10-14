#!/usr/bin/env bash

/usr/bin/pulseaudio -k
/usr/bin/pulseaudio --start

/usr/bin/bluetoothctl << EOF connect 08:DF:1F:8D:2B:C6 EOF quit
