#!/bin/bash

if [ -d "$HOME" ]; then
   HPATH=$HOME
elif [ -d "/home/$USER" ]; then
   HPATH=/home/$USER
else
   echo "Unable to Find user HOME folder!!!!"
   exit 1
fi

legacy_mode() {
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$RKEY"
}

newer_mode() {
  # o use OpenSSH format instead of PEM.
  # a Key Derivatrion Function rounds...16 is default, the higher is slower but reduces brute force attacks.
  ssh-keygen -o -a 120 -t ed25519 -C "$email" -f "$RKEY"
}

make_a_key() {

    if [ "$UID" -eq 0 ]; then
      echo "Be a regular user, not ROOT...!"
      exit 1
    fi

    if [ ! -d "$HPATH/.ssh" ]; then
       mkdir "$HPATH/.ssh"
       chmod 700 "$HPATH/.ssh"
    fi

    cd "$HPATH/.ssh" || { echo "Unable to cd into $HPATH/.ssh !"; exit 1; }
    RKEY=$HPATH/.ssh/${USER}_key

    if [ -f "${RKEY}.private" ] || [ -f "${RKEY}.pub" ]; then
       echo -e "\nKey already made...!\n"
       echo "Enter name for new key, if you want another: "
       read -r newkey
       if [ -z "$newkey" ]; then
          exit 1
       fi
       RKEY=$HPATH/.ssh/${newkey}_key
    fi

    echo -e "\nCreating an SSH Key..."
    echo -e "\nWhat is your email address?:"
    read -r email
    if [ -z "$email" ]; then
       echo "No Email Supplied, exiting!"
       exit 1
    fi
    echo -e "\nUse RSA for older Legacy systems or Ed25519 for Newer Systems\n"
    read -r -p "L) Legacy N) Newer Systems : " runas
    case runas in
      l | L) legacy_mode;;
      *) newer_mode;;
    esac

    mv "$RKEY" "${RKEY}.private"
    echo "Made Private Key @ ${RKEY}.private :: Keep it SAFE!"
    read -n 1 -s -r -p "Hit enter or press any key to continue:"

}

make_a_key ##

# Source: https://medium.com/risan/upgrade-your-ssh-key-to-ed25519-c6e8d60d3c54
# 🚨 DSA: It’s unsafe and even no longer supported since OpenSSH version 7, you need to upgrade it!
# ⚠️  RSA: It depends on key size. If it has 3072 or 4096-bit length, then you’re good. Less than that, you probably want to upgrade it. The 1024-bit length is even considered unsafe.
# 👀 ECDSA: It depends on how well your machine can generate a random number that will be used to create a signature. There’s also a trustworthiness concern on the NIST curves that being used by ECDSA.
# ✅ Ed25519: It’s the most recommended public-key algorithm available today!
