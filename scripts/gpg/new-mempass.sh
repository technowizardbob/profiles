#!/bin/bash
source ${_PROFILES_PATH}scripts/gpg/common-helper.sh

new-mempass() {
  if [ -z "$1" ]; then
     echo "Please assign system-name, example: email/bob@example.com"
  else
     _parse_gpg_system_name "$1"
     if [ $? -ne 0 ]; then
        rm $XNP_GPG_TEMP
        return 1
     fi
     if [ -z "$myGPG_file" ]; then
        rm $XNP_GPG_TEMP
        return 1
     fi

     local syb_size=2
     local syb1=$(tr -dc '!@#^&*(){}[];:,.?' < /dev/urandom | head -c $syb_size)
     local syb2=$(tr -dc '!@#^&*(){}[];:,.?' < /dev/urandom | head -c $syb_size)

     echo -e "$syb1$(shuf -n 3 /usr/share/dict/british-english | sed "s/./\u&/" | tr -cd "[A-Za-z]"; echo $(shuf -i0-999 -n 1))$syb2" > $XNP_GPG_TEMP
     _do_gpg_stuff "$2"
  fi
}
new-mempass "$1" "$2"
