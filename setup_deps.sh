#!/bin/bash

pushd /opt/profiles > /dev/null

if [ -e .ran_setup ]; then
   echo "Setup Already completed, successfully I think!"
   echo "If it did not install everything, then \$ rm .ran_setup"
   exit 1
fi
   
if [ ! -r arch_deps.list ] || [ ! -r debian_deps.list ] || \
   [ ! -d /opt/profiles ]; then
   echo -e "Setup FAILED to install, as it could not find its default path of /opt/profiles, or could not find arch_deps.list, or debian_deps.list \n- required for setup!\n"
   echo "Please have this git repo in /opt/profiles"
   echo "Then cd into it, \$ cd /opt/profiles"
   echo "Explore....around....enjoy"
   exit 1
fi

if [ -x /bin/pacman ] || [ -x /usr/bin/pacman ]; then
   sudo pacman -Syu
   sudo pacman -S $(cat arch_deps.list)
elif [ -x /bin/apt-get ] || [ -x /usr/bin/apt-get ]; then
   sudo apt-get update
   sudo apt-get install $(cat debian_deps.list)
fi

if [ $? -eq 0 ]; then
   touch .unicode_support
   touch .ran_setup
   if [ ! -f /home/$USER/.ran_profiles_once ]; then
      echo -e "Success!\nNow run install.sh if you have not already..."
   fi
fi

popd > /dev/null
