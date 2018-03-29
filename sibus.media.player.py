#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import socket
import time

from sibus_lib import BusClient, sibus_init
from sibus_lib.utils import handle_signals, exec_process

SERVICE_NAME = "media.player"
logger, cfg_data = sibus_init(SERVICE_NAME)


def say(phrase):
    logger.info("Received request for TTS: '%s'" % phrase)

    filepath = "/tmp/picotts.wav"

    try:
        logger.info("Text to speach: %s" % phrase)
        exec_process("/usr/bin/pico2wave -w %s -l fr-FR \"%s\"" % (filepath, phrase))
    except Exception as e:
        logger.error("Error while playing file: %s" % filepath)
        return False

    try:
        logger.info("Playing file: %s" % filepath)
        exec_process("/usr/bin/aplay \"%s\"" % filepath)
    except Exception as e:
        logger.error("Error while playing file: %s" % filepath)
        return False

    os.remove(filepath)
    return True


def on_busmessage(topic, payload):
    logger.info(payload)

    if topic.endswith("TTS"):
        say(payload["value"])


# exec_process("./connect_bt.sh")

busclient = BusClient(socket.getfqdn(), SERVICE_NAME, onmessage_cb=on_busmessage)
busclient.mqtt_subscribe("sibus/+/TTS")

busclient.start()

handle_signals()
try:
    while 1:
        time.sleep(1)
except (KeyboardInterrupt):
    logger.info("Ctrl+C detected !")
except Exception as e:
    logger.exception("Exception in program detected ! \n" + str(e))
finally:
    busclient.stop()
    logger.info("Terminated !")
