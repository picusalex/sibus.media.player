#!/usr/bin/env python
# -*- coding: utf-8 -*-

import signal
import sys
import time

from sibus_lib import BusElement, MessageObject, sibus_init
from sibus_lib.VoiceRSSWrapper import TextToSpeech, AudioPlayer

SERVICE_NAME = "media.player"
logger, cfg_data = sibus_init(SERVICE_NAME)

def on_busmessage(message):
    logger.info(message)

    if message.topic == "request.audio.tts":
        data = message.get_data()
        logger.info("Received request for TTS: '%s'"%data["tts"])

        tts = TextToSpeech(data["tts"])
        filepath = tts.generateMP3()

        emit_msg = MessageObject(topic="request.audio.play", data={
            "type": "file",
            "filename": filepath,
            "content": tts.get_mp3_data()
        })
        busclient.publish(emit_msg)

    if message.topic == "request.audio.play":
        data = message.get_data()
        logger.info("Received request for Play")

        if data["type"] == "file":
            mp3file = AudioPlayer()
            filepath = mp3file.create_mp3file(data["content"])
            mp3file.playfile(filepath)


busclient = BusElement(SERVICE_NAME, callback=on_busmessage, ignore_my_msg=False)
busclient.register_topic("request.audio.tts")
busclient.register_topic("request.audio.play")
busclient.start()

def sigterm_handler(_signo=None, _stack_frame=None):
    busclient.stop()
    logger.info("Program terminated correctly")
    sys.exit(0)

signal.signal(signal.SIGTERM, sigterm_handler)

try:
    while 1:
        time.sleep(5)
except (KeyboardInterrupt, SystemExit):
    logger.info("Ctrl+C detected !")
except:
    logger.error("Program terminated incorrectly ! ")
    sys.exit(1)
    pass

sigterm_handler()
