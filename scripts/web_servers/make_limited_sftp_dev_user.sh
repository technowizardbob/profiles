#!/bin/bash
if [ "$UID" -ne "0" ]; then
  echo "Please sudo first....!"
  exit
fi

if [ -z "$1" ]; then
  echo "Enter Developers UserName - will add Groups: sftp!"
fi

if [ ! -d /var/webjails ]; then
   mkdir /var/webjails
   chown root:root /var/webjails
   chmod 775 /var/webjails
fi

user_exists() { id "$1" &>/dev/null; }
if ! user_exists "$1"; then
    adduser -m -d /var/webjails "$1"
fi

if [ $(cat /etc/group | grep -c "sftp:") -eq 0 ]; then
   groupadd sftp
fi

usermod --shell /sbin/nologin "$1"
usermod -g sftp "$1"
