#!/bin/bash

# Based on SICP protocol reference from https://community.xibo.org.uk/uploads/short-url/vwVq2nPyhJKL4kTCYpa6VYhQUa8.pdf
# In this version: set RGB LED strip state and color.
# Usage: ./philips_ds_set.sh < | [R] [G] [B]>
# With 0 arguments it turns off the LED strip
# With 3 arguments (R G B) it turns on the LED strip with selected color. Color codes are decimal (0-255).

# Remote device config
IP=192.168.60.156
PORT=5000

xor_checksum() {
  arr=("$@")
  for el in "${arr[@]}"; do
    CHECKSUM=$((CHECKSUM^$el))
  done
}

list_to_bytes() {
  arr=("$@")
  CMD_PART=""
  for el in "${arr[@]}"; do
    CMD_PART+=$(printf "%s%02X" "\x" "$el")
  done
}

# Message-Set (example)
# Byte 1: 0x09: Total message size is 9 bytes
# Byte 2: 0x01: Monitor ID (default)
# Byte 3: 0x00: Group ID (Control by Monitor ID)
# Byte 4: 0xF3: LED STRIP set for 10BDL3051T
# Byte 5: 0x01: Turn on light
# Byte 6: 0xFF: Red value
# Byte 7: 0x00: Green value
# Byte 8: 0x00: Blue value
# Byte 9: 0x05: Checksum as bitwise XOR of bytes 1-4

PREFIX=(9 1 0 243)
xor_checksum ${PREFIX[@]}
list_to_bytes ${PREFIX[@]}

CMD_PREFIX=$CMD_PART
CMD_ACTION=""
CMD_OFF=0
CMD_ON=1
CMD_RGB=""
CMD_CHECKSUM=""

if [ "$#" -eq 0 ]; then
  RGB=(0 0 0)
  xor_checksum $CMD_OFF
  list_to_bytes $CMD_OFF
  CMD_ACTION=$CMD_PART
elif [ "$#" -eq 3 ]; then
  RGB=($1 $2 $3)
  xor_checksum $CMD_ON
  list_to_bytes $CMD_ON
  CMD_ACTION=$CMD_PART
else
  echo "Illegal number of parameters" >&2
  exit
fi

xor_checksum ${RGB[@]}
list_to_bytes ${RGB[@]}
CMD_RGB=$CMD_PART
list_to_bytes $CHECKSUM
CMD_CHECKSUM=$CMD_PART

#cat <(echo -n -e "\x09\x01\x00\xf3\x00\xff\x00\x00\x04") - | nc -v -w 1 192.168.60.156 5000|hexdump -C
#cat <(printf "${CMD_PREFIX}${CMD_ACTION}${CMD_RGB}${CMD_CHECKSUM}") - | nc -v -w 1 192.168.60.156 5000|hexdump -C
printf "${CMD_PREFIX}${CMD_ACTION}${CMD_RGB}${CMD_CHECKSUM}" | nc $IP $PORT
