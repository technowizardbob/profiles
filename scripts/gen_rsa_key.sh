#!/bin/bash

if [ $UID -eq 0 ]; then
  echo "Be a regular user, not ROOT...!"
  exit 1
fi

if [ ! -d ~/.ssh ]; then
   mkdir ~/.ssh
   chmod 700 ~/.ssh
fi

cd ~/.ssh
RKEY=~/.ssh/${USER}_rsa

if [ -f "${RKEY}.private" ]; then
   echo "RSA key already made...!"
   exit 1
fi

echo -e "\nCreating SSH RSA Keys..."
echo -e "\nWhat is your email address?:"
read email
if [ -z $email ]; then
   echo "No Email Supplied, exiting!"
   exit 1
fi
ssh-keygen -t rsa -b 4096 -C "$email" -f "$RKEY"
mv "$RKEY" "${RKEY}.private"
echo "Made Private Key @ ${RKEY}.private :: Keep it SAFE!"
