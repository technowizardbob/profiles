_parse_gpg_system_name() {
  if [ ! -x $XGPG_APP ]; then
     echo -e "Please install the gpg program!\n"
     return 1
  fi
  if [ $(which pass | wc -l) -ne 1 ]; then
     echo "You should install the pass program!"
     echo -e "pass: the standard unix password manager.\n"
  fi
  if [ ! -d "$XGPG_PASS_STORE" ]; then
     echo -e "GPG PASS program has not made the ~/.password-store folder yet! Bailing!\n"
     return 1
  fi
  if [ -z $(which mktemp) ]; then
     XNP_GPG_TEMP=/tmp/np
  else
     XNP_GPG_TEMP=$(mktemp)
  fi

  saveIFS=$IFS
  IFS="/"
  local parts=($1)
  IFS=$saveIFS
  local count_gp=${#parts[@]}

  local part1=${parts[0]}
  if [ $count_gp -eq 1 ]; then
     myGPG_folder=""
     myGPG_file="$part1"
     return 0
  fi
  if [ $count_gp -eq 2 ]; then
     local part2=${parts[1]}
     myGPG_folder="$XGPG_PASS_STORE/$part1"
     myGPG_file="$part2"
     return 0
  fi
  if [ $count_gp -gt 2 ]; then
    local part2=${parts[1]}
    local lastthing=${1##*/}
    myGPG_folder="$XGPG_PASS_STORE/$part1/$part2"
    myGPG_file="$lastthing"
    return 0
  fi
  echo "Invaild System Name."
  return 1
}

_do_gpg_stuff() {
  if [ -f $XNP_GPG_TEMP.gpg ]; then
    rm $XNP_GPG_TEMP.gpg
  fi

  read -r -p "Enter extra comments (optional):" comments
  if [ -n "$comments" ]; then
     echo "$comments" >> $XNP_GPG_TEMP
  fi

  if [ -z "$1" ]; then
     $XGPG_APP -r "$XGPG_EMAIL" --encrypt $XNP_GPG_TEMP
     if [ $? -ne 0 ]; then
       echo "GPG unable to find user's email of $GPG_EMAIL"
       echo "Edit by: cmd gpg --edit"
       rm $XNP_GPG_TEMP
       return 1
     fi
  else
     $XGPG_APP -r "$1" --encrypt $XNP_GPG_TEMP
     if [ $? -ne 0 ]; then
       echo "GPG unable to find user's email of $1"
       rm $XNP_GPG_TEMP
       return 1
     fi
  fi

  cat $XNP_GPG_TEMP
  rm $XNP_GPG_TEMP

  if [ -n "$myGPG_folder" ]; then
    mkdir -p "$myGPG_folder"
    mv $XNP_GPG_TEMP.gpg "$myGPG_folder/$myGPG_file.gpg"
  else
     mv $XNP_GPG_TEMP.gpg "$XGPG_PASS_STORE/$myGPG_file.gpg"
  fi
}
