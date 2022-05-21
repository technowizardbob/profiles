#!/bin/bash

SANE_CHECKER=/opt/profiles/sane_checker.sum
SHA_SUM_APP=/usr/bin/sha256sum
MAIL_FOLDER=/var/mail

if groups "$USER" | grep -o "sudo" >/dev/null 2>/dev/null; then
   USE_SUPER="sudo"
elif groups "$USER" | grep -o "doas" >/dev/null 2>/dev/null; then
   USE_SUPER="doas"
elif groups "$USER" | grep -o "wheel" >/dev/null 2>/dev/null; then
   USE_SUPER="sudo"
elif groups "$USER" | grep -o "admin" >/dev/null 2>/dev/null; then
   USE_SUPER="sudo"
elif [ "$EUID" -eq 0 ]; then
   USE_SUPER="\$"
else
   USE_SUPER=""
fi

FAILED=0

#shaXsum
require_root() {
  if [ "$EUID" -eq 0 ]; then
    chmod 444 "$SANE_CHECKER"
    chattr +i "$SANE_CHECKER"
  else
    echo "Trying to make sane sum file Immutable for security purposes, Please enter ROOT password when prompted."
    if [ -n "$USE_SUPER" ] && sudo --validate; then
       sudo chmod 444 "$SANE_CHECKER"
       sudo chattr +i "$SANE_CHECKER"
    else
       echo "Please have a ROOT user make this file: $SANE_CHECKER Immutable!"
    fi
  fi
}
prompter_for_fix() {
   echo "Verify the integerity of your aliases scripts, then run:"
   if [ ! -w "$SANE_CHECKER" ]; then
      echo -e "\r\n sudo chattr -i \"$SANE_CHECKER\" \r\n sudo chmod 664 \"$SANE_CHECKER\" \r\n rm $SANE_CHECKER"
   else
      echo -e "rm $SANE_CHECKER"
   fi
}
if [ ! -f "$SANE_CHECKER" ]; then
   $SHA_SUM_APP {/opt/profiles/aliases/*.env,/opt/profiles/custom_aliases/*.env,~/.bash_aliases,~/.bashrc,~/.bash_logout,~/.git_bash_prompt,~/.profile,~/.kube-ps1} > "$SANE_CHECKER" 2>/dev/null
   echo -e "\033[0;34m 1st run added to sane sum file! \033[0m"
   require_root
else
   if [ -w "$SANE_CHECKER" ]; then
      echo -e "\033[0;31m Warning -- sane sum Security file is Mutable! Please have a Root User run: \r\n \033[0m sudo chmod 444 \"$SANE_CHECKER\" \r\n AND then run \r\n sudo chattr +i \"$SANE_CHECKER\" \r\n"
   fi
   for FILE in /opt/profiles/aliases/*.env; do
       if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
          echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses. \033[0m"
          FAILED=1
       fi
   done
   for FILE in /opt/profiles/custom_aliases/*.env; do
       if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
          echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses. \033[0m"
          FAILED=1
       fi
   done
   if ! $SHA_SUM_APP --quiet -c "$SANE_CHECKER"; then
      echo -e "\033[0;31m Danger...? Failed Sane checker!! \033[0m"
      FAILED=1
   else
      if [ $FAILED -eq 0 ]; then
         echo -e "\033[0;32m All seems normal...Passed sane tests. \033[0m"
      fi
   fi
fi

if [ $FAILED -eq 1 ]; then
   prompter_for_fix
fi

del_mail() {
   if [ ! -f "$MAIL_FOLDER/$1" ]; then
      return
   fi
   if [ $(sudo cat "$MAIL_FOLDER/$1" | wc -l) -eq 0 ]; then
      sudo rm "$MAIL_FOLDER/$1"
      return
   fi

   read -r -p "Would you like to save your mail or delete it [save or delete] : " keep
   if [ "$keep" == "delete" ] || [ "$keep" == "del" ]; then
	echo "Attempting to erase mail for user root."
	sudo rm "$MAIL_FOLDER/$1"
   fi
}

read_mail() {
   if [ ! -f "$MAIL_FOLDER/$1" ]; then
      return
   fi

   if [ "$1" == "root" ] && [ $EUID -ne 0 ] && [ -z "$USE_SUPER" ]; then
      echo "Have your Root user check his mailbox as ${MAIL_FOLDER}/root has Mail in it!"
      return
   fi

   echo "Checking if $1 has any mail...."
   if [ $(sudo cat "$MAIL_FOLDER/$1" | wc -l) -eq 0 ]; then
      echo "No new mail"
      sudo rm "$MAIL_FOLDER/$1"
      return
   fi
   echo "$1 HAS Mail!!!"
   if [ -x /usr/bin/mutt ]; then
      if [ "$1" == "root" ]; then
         sudo mutt -f "$MAIL_FOLDER/$1"
      else
         mutt -f "$MAIL_FOLDER/$1"
      fi
   elif [ -x /usr/bin/mail ]; then
      read -r -p "Check mail via [ mail, less, nano, tail, read, or cat ] : " check
      case $check in
          mail) sudo mail -u "$1";;
          less) sudo less "$MAIL_FOLDER/$1";;
          nano) sudo nano "$MAIL_FOLDER/$1";;
          tail) sudo tail -n 50 "$MAIL_FOLDER/$1";;
          *) sudo cat "$MAIL_FOLDER/$1";;
      esac
   else
      read -r -p "Check mail via [ less, nano, tail, read, or cat ] : " check
      case $check in
          less) sudo less "$MAIL_FOLDER/$1";;
          nano) sudo nano "$MAIL_FOLDER/$1";;
          tail) sudo tail -n 50 "$MAIL_FOLDER/$1";;
          *) sudo cat "$MAIL_FOLDER/$1";;
      esac
   fi
   del_mail "$1"
}

# Check for Root Mail Alerts, to keep up to date on Security Issues
read_mail root

if [ "$USER" != "root" ]; then
   read_mail "$USER"
fi

bail() {
   if [ $FAILED -eq 1 ]; then
      exit 1
   fi
   exit 0
}

# Check for TripWire Program
if [ -f ~/.no_tripwire_check ] || [ -f /opt/profiles/.no_tripwire_check ]; then
   bail
fi
if which tripwire >/dev/null 2>/dev/null; then
   bail
fi

if [ -z "$USE_SUPER" ]; then
   echo "Have a root user install tripwire..."
   bail
fi

echo -e "\r\n For better security, remember to install the tripwire program. \r\n Also, write down in a safe place the Site & Local keys -- passphrases it will prompt you to make up! \r\n"

declare -A osInfo;
osInfo[/etc/redhat-release]="yum install OR dnf install"
osInfo[/etc/arch-release]="pacman -S"
osInfo[/etc/gentoo-release]="emerge"
osInfo[/etc/SuSE-release]="zypper install"
osInfo[/etc/debian_version]="apt-get install"
osInfo[/etc/alpine-release]="apk add --no-cache"
for f in "${!osInfo[@]}"
do
   if [[ -f $f ]];then
      echo "Use your package manager to do something like: ${USE_SUPER} ${osInfo[$f]} tripwire"
      echo "Google linux tripwire for more info...as its complex."
   fi
done
bail
