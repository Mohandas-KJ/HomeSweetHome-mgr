#!/bin/bash

CONFIG_FILE="config/secrets.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Connfig File not found!"
    exit 1
fi

source "$CONFIG_FILE"
echo "Loaded Configuration File"

echo "Sending WoL......"

wol "$MAC"
sleep 150

ping -c 3 "$IP"