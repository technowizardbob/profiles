#!/bin/bash
cd /tmp
#wget https://github.com/Peltoche/lsd/releases/download/0.19.0/lsd_0.19.0_amd64.deb
#sudo dpkg -i lsd_0.19.0_amd64.deb
wget https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd_0.23.1_amd64.deb
if sudo dpkg -i lsd_0.23.1_amd64.deb
then
   rm /tmp/lsd_0.23.1_amd64.deb
fi
