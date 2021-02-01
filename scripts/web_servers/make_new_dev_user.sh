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

usermod -a -G sudo "$1"
usermod -g www-data "$1"
