#!/bin/bash

#Detect the name of the display in use
display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

#Detect the user using such display
user=$(who | grep "($display)" | awk '{print $1}')

#Detect the id of the user
#uid=$(id -u $user)

who=$(whoami)
[ ! "$user" = "$who" ] && {
    echo "Only the current GUI user ${user} can use this screen!"
    echo "BTW - this error may happen also if switched users in GUI...so ignore it...then."
    exit 1
}
