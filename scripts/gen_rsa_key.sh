#!/bin/bash

if [ -d "$HOME" ]; then
   HPATH=$HOME
elif [ -d "/home/$USER" ]; then
   HPATH=/home/$USER
else
   echo "Unable to Find user HOME folder!!!!"
   exit 1
fi

gen_rsa_key() {

    if [ "$UID" -eq 0 ]; then
      echo "Be a regular user, not ROOT...!"
      exit 1
    fi

    if [ ! -d "$HPATH/.ssh" ]; then
       mkdir "$HPATH/.ssh"
       chmod 700 "$HPATH/.ssh"
    fi

    cd "$HPATH/.ssh" || { echo "Unable to cd into $HPATH/.ssh !"; exit 1; }
    RKEY=$HPATH/.ssh/${USER}_rsa

    if [ -f "${RKEY}.private" ] || [ -f "${RKEY}.pub" ]; then
       echo -e "\nRSA key already made...!\n"
       echo "Enter name for new key, if you want another:"
       read -r newkey
       if [ -z "$newkey" ]; then
          exit 1
       fi
       RKEY=$HPATH/.ssh/${newkey}_rsa
    fi

    echo -e "\nCreating SSH RSA Keys..."
    echo -e "\nWhat is your email address?:"
    read -r email
    if [ -z "$email" ]; then
       echo "No Email Supplied, exiting!"
       exit 1
    fi
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$RKEY"
    mv "$RKEY" "${RKEY}.private"
    echo "Made Private Key @ ${RKEY}.private :: Keep it SAFE!"
    read -n 1 -s -r -p "Hit enter or press any key to continue:"

}

gen_rsa_key ##
