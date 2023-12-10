#!/bin/bash

# Based on SICP protocol reference from https://community.xibo.org.uk/uploads/short-url/vwVq2nPyhJKL4kTCYpa6VYhQUa8.pdf
# Returns JSON response: { state: <0,1>, rgb_color: <0-255>, <0-255>, <0-255> }
# In this version: RGB LED strip state and color.

# Remote device config
IP=192.168.60.156
PORT=5000

# Message-Get (Report)
# Byte 1: 0x05: Total message size is 5 bytes
# Byte 2: 0x01: Monitor ID (default)
# Byte 3: 0x00: Group ID (Control by Monitor ID)
# Byte 4: 0xF4: LED STRIP status get for 10BDL3051T
# Byte 5: 0xF0: Checksum as bitwise XOR of bytes 1-4
CMD=$((echo -n -e "\x05\x01\x00\xf4\xf0"; sleep 5) | nc $IP $PORT|od -vt x1 -A n|xargs)
IFS=' ' read -r -a RET <<< "$CMD"
printf '{"state":%d,"rgb_color":"%d, %d, %d"}\n' "0x"${RET[4]} "0x"${RET[5]} "0x"${RET[6]} "0x"${RET[7]}
