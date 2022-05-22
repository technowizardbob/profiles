#!/bin/bash
if [ "$UID" -ne "0" ]; then
  echo "Please sudo first....!"
  exit
fi

if [ -z "$1" ]; then
  echo "Enter Developers UserName - will add Groups: sudo and www-data!"
fi

user_exists() { id "$1" &>/dev/null; }
if ! user_exists "$1"; then
    adduser "$1"
fi

if [ $(cat /etc/group | grep -c "web-admin:") -eq 0 ]; then
   groupadd web-admin
fi

usermod -a -G www-data "$1"
usermod -g sudo "$1"
usermod -g web-admin "$1"
