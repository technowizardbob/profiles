#!/bin/bash
if [ ! -r arch_deps.list ] || [ -r debian_deps.list ] || \
   [ ! -d /opt/profiles ]; then
   echo "Please have this git repo in /opt/profiles"
   echo "Then cd into it, \$ cd /opt/profiles"
   exit 1
fi

if [ -x /bin/pacman ] || [ -x /usr/bin/pacman ]; then
   sudo pacman -Syu
   sudo pacman -S $(cat arch_deps.list) 
elif [ -x /bin/apt-get ] || [ -x /usr/bin/apt-get ]; then
   sudo apt-get update
   sudo apt-get install -y $(cat debian_deps.list)
fi

if [ $? -eq 0 ]; then
   echo -e "Success!\nNow run install.sh if you have not already..."
fi
