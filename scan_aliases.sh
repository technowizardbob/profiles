#!/bin/bash

SANE_CHECKER="${_PROFILES_PATH}sane_checker.sum"
SHA_SUM_APP=/usr/bin/sha256sum

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

SANE_TEST_FAILED=0

tmpsum=$(mktemp -u --suffix ".sum.tmp")

#shaXsum
require_root() {
  if [ "$EUID" -eq 0 ]; then
    mv "$tmpsum" "$SANE_CHECKER"
    chown root:root "$SANE_CHECKER"
    chmod 444 "$SANE_CHECKER"
    chattr +i "$SANE_CHECKER"
  else
    echo "Trying to make sane sum file Immutable for security purposes, Please enter ROOT password when prompted."
    if [ -n "$USE_SUPER" ] && sudo --validate; then
       sudo mv "$tmpsum" "$SANE_CHECKER"
       sudo chown root:root "$SANE_CHECKER"
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
   echo -e "\033[0;34m 1st run added to sane sum file! \033[0m"
   $SHA_SUM_APP {/opt/profiles/*.sh,/opt/profiles/aliases/*.env,/opt/profiles/custom_aliases/*.env,~/.bash_aliases,~/.bashrc,~/.bash_logout,~/.git_bash_prompt,~/.profile,~/.kube-ps1,/opt/profiles/theme} > "$tmpsum" 2>/dev/null
   require_root
else
   if [ -w "$SANE_CHECKER" ]; then
      echo -e "\033[0;31m Warning -- sane sum Security file is Mutable! Please have a Root User run: \r\n \033[0m sudo chmod 444 \"$SANE_CHECKER\" \r\n AND then run \r\n sudo chattr +i \"$SANE_CHECKER\" \r\n"
   fi
   for FILE in /opt/profiles/aliases/*.env; do
       if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
          echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses. \033[0m"
          SANE_TEST_FAILED=1
       fi
   done
   for FILE in /opt/profiles/custom_aliases/*.env; do
       if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
          echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses. \033[0m"
          SANE_TEST_FAILED=1
       fi
   done
   if ! $SHA_SUM_APP --quiet -c "$SANE_CHECKER"; then
      echo -e "\033[0;31m Danger...? Failed Sane checker!! \033[0m"
      SANE_TEST_FAILED=1
   fi
fi

if [ $SANE_TEST_FAILED -eq 1 ]; then
   prompter_for_fix
fi
