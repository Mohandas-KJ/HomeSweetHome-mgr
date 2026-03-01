#!/bin/bash

if [ $EUID -ne 0 ];then
    echo "Run it as Sudo"
    exit 1
fi

TARGET="0004"

efibootmgr -n "$TARGET"