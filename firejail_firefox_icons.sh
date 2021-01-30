#!/bin/bash
if [ -z "$1" ]; then
   echo "option --all_users  will install the desktop icon for all users."
   echo "option --me will install the desktop icon just for you."
elif [ $1 == "--all_users" ]; then
   set -x
   sudo mv /usr/share/applications/firefox.desktop /usr/share/applications/firefox.desktop.backup
   sudo ln -s /opt/profiles/dotfiles/firefox.desktop /usr/share/applications/
   set +x
elif [ $1 == "--me" ]; then
   if [ -d $HOME ]; then
      set -x
      mv $HOME/.local/share/applications/firefox.desktop $HOME/.local/share/applications/firefox.desktop.backup
      ln -s /opt/profiles/dotfiles/firefox.desktop $HOME/.local/share/applications/
      set +x
   elif [ -d /home/$USER ]; then
      set -x
      mv /home/$USER/.local/share/applications/firefox.desktop /home/$USER/.local/share/applications/firefox.desktop.backup
      ln -s /opt/profiles/dotfiles/firefox.desktop /home/$USER/.local/share/applications/
      set +x
   else
      echo "Unable to find home folder!!!!"
   fi
fi
