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
	echo "Attempting to erase mail for user $1."
	sudo rm "$MAIL_FOLDER/$1"
   fi
}

read_mail() {
   if [ ! -f "$MAIL_FOLDER/$1" ]; then
      return
   fi

   if [ $EUID -ne 0 ] && [ -z "$USE_SUPER" ]; then
      echo "Have your Root user check the mailbox for ${MAIL_FOLDER}/$1 has Mail in it!"
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
