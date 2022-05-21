#!/bin/bash
SANE_CHECKER=/opt/profiles/sane_checker.sum
require_root() {
  if [ "$EUID" -eq 0 ]; then
    chmod 444 "$SANE_CHECKER"
    chattr +i "$SANE_CHECKER"
  else
    echo "Trying to make sane sum file Immutable for security purposes, Please enter ROOT password when prompted."
    if sudo --validate; then
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
   sha1sum {/opt/profiles/aliases/*.env,/opt/profiles/custom_aliases/*.env,~/.bash_aliases,~/.bashrc,~/.bash_logout,~/.git_bash_prompt,~/.profile,~/.kube-ps1} > "$SANE_CHECKER"
   echo -e "\033[0;34m 1st run added to sane sum file!"
   require_root
else
   if [ -w "$SANE_CHECKER" ]; then
      echo -e "\033[0;31m Warning -- sane sum Security file is Mutable! Please have a Root User run: \r\n \033[0m sudo chmod 444 \"$SANE_CHECKER\" \r\n AND then run \r\n sudo chattr +i \"$SANE_CHECKER\" \r\n"
   fi
   for FILE in /opt/profiles/aliases/*.env; do
       if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
          echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses."
          prompter_for_fix
          exit 1
       fi
   done
   for FILE in /opt/profiles/custom_aliases/*.env; do
       if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
          echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses."
          prompter_for_fix
          exit 1
       fi
   done
   if ! sha1sum --quiet -c "$SANE_CHECKER"; then
      echo -e "\033[0;31m Danger...? Failed Sane checker!!"
      prompter_for_fix
   else
      echo -e "\033[0;32m All seems normal...Passed sane tests."
   fi
fi
if [ -f "/var/mail/root" ]; then
   echo "Checking if Root has any mail...."
   if [ $(sudo cat /var/mail/root | wc -l) -eq 0 ]; then
      echo "No new mail"
      sudo rm /var/mail/root
      exit 0
   fi
   echo "Root HAS Mail!!!"
   if [ -x /usr/bin/mail ]; then
      read -r -p "Check ROOT mail via [ mail, less, nano, tail, read, or cat ] : " check
      case $check in
              mail) sudo mail -u root;;
              less) sudo less /var/mail/root;;
              nano) sudo nano /var/mail/root;;
              tail) sudo tail -n 50 /var/mail/root;;
              *) sudo cat /var/mail/root;;
      esac
   else
      read -r -p "Check ROOT mail via [ less, nano, tail, read, or cat ] : " check
      case $check in
              less) sudo less /var/mail/root;;
              nano) sudo nano /var/mail/root;;
              tail) sudo tail -n 50 /var/mail/root;;
              *) sudo cat /var/mail/root;;
      esac
   fi
   read -r -p "Would you like to save your mail or delete it [save or delete] : " keep
   if [ "$keep" == "delete" ] || [ "$keep" == "del" ]; then
      echo "Attempting to erase mail for user root."
      sudo rm /var/mail/root
   fi
fi
