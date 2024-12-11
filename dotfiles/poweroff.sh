#!/bin/bash
zenity --question --width 300 --text "Sure you want to PowerOff?";
if [[ $? -eq 0 ]]; then
    shutdown -P -h now
fi
