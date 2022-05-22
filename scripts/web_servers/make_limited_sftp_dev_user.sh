#!/bin/bash

WebJAIL=/var/www/webjails
chmod 755 /var/www
chown root:root /var/www

if [ "$UID" -ne "0" ]; then
  echo "Please sudo first....!"
  exit
fi

if [ -z "$1" ]; then
  echo "Enter Developers UserName - will add Groups: sftp!"
fi

if [ ! -d "$WebJAIL" ]; then
   mkdir -p "${WebJAIL}/project1"
   chown root:root "$WebJAIL"
   chmod 755 "$WebJAIL"
   chown "${1}:www-data" "${WebJAIL}/project1"
   chmod 775 "${WebJAIL}/project1"
fi

user_exists() { id "$1" &>/dev/null; }
if ! user_exists "$1"; then
    adduser -m -d "$WebJAIL" "$1"
fi

if [ $(cat /etc/group | grep -c "sftp-user:") -eq 0 ]; then
   groupadd sftp-user
fi

usermod --shell /sbin/nologin "$1"
usermod -g www-data "$1"
usermod -a -G sftp-user "$1"
