#!/bin/bash
SANE_CHECKER=/opt/profiles/sane_checker.sum
if [ ! -f "$SANE_CHECKER" ]; then
   sha1sum /opt/profiles/aliases/*.env > "$SANE_CHECKER"
   sha1sum ~/.bash_aliases >> "$SANE_CHECKER"
   sha1sum ~/.bashrc >> "$SANE_CHECKER"
   sha1sum ~/.bash_logout >> "$SANE_CHECKER"
   sha1sum ~/.git_bash_prompt >> "$SANE_CHECKER"
   sha1sum ~/.profile >> "$SANE_CHECKER"
   sha1sum ~/.kube-ps1 >> "$SANE_CHECKER"
   echo -e "\033[0;34m 1st run added to sane sum file!"
else
   for FILE in /opt/profiles/aliases/*.env; do
       if ! grep -q "$FILE" "$SANE_CHECKER"; then
          echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses."
          exit 1
       fi
   done
   sha1sum --quiet -c "$SANE_CHECKER"
   if [ $? -ne 0 ]; then
      echo -e "\033[0;31m Danger...? Failed Sane checker!!"
   else
      echo -e "\033[0;32m All seems normal...Passed sane tests."
   fi
fi
