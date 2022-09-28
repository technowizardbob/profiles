#!/bin/bash
source ${_PROFILES_PATH}scripts/gpg/common-helper.sh

new-pwd() {
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

     local syb_size=3
     local syb1=$(tr -dc '!@#^&*(){}[];:,.?' < /dev/urandom | head -c $syb_size)
     local syb2=$(tr -dc '!@#^&*(){}[];:,.?' < /dev/urandom | head -c $syb_size)

     echo "$syb1$(openssl rand -base64 $XNEW_PASSWORD_SIZE)$syb2" > $XNP_GPG_TEMP
     _do_gpg_stuff "$2"
  fi
}
new-pwd "$1" "$2"
