#!/bin/bash

sleep 30

xfce4-terminal --command="bash -c '
figlet HoSweetHo | lolcat
echo Next Boot Configured
echo Ready
sleep 4
' "