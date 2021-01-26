add_sshkey() { 
  clear
  IFSOLD=$IFS
  IFS=$'\n'
  homes=~/.ssh/
  akeys=( "Default" "${KEY/$homes/}" )
  realkeys=( "${KEY}" )
  indexforkeys=( "Default" )
  option_no=0
  local pubs=$(find ~/.ssh/ -type f -iname "*.pub")
  if [ -z $pubs ]; then
     echo "You have no KEYs, copy your existing ones or make a new one...."
     echo "To make a key do \$ /opt/profiles/scripts/gen_rsa_key.sh"
     exit 1
  fi
  for k in $pubs; do
    if [ $k == "$KEY" ]; then 
       continue
    fi
       
    option_no=$((option_no+1))
    akeys+=( "$option_no" "${k/$homes/}" )
    indexforkeys+=( "$option_no" )
    realkeys+=( "$k" )
  done
  IFS=$IFSOLD
  
  usekey=$(dialog --ok-label "Use this Key" --cancel-label "Back" --output-fd 1 \
                    --colors \
                    --menu "Select key:" 0 0 0 "${akeys[@]}")
  
  match="false"                  
  c=0
  for no in "${indexforkeys[@]}"; do
    c=$((c+1))
    if [ "$usekey" == "$no" ]; then
       match="true"
       break
    fi
  done
  
  if [ "$match" == "false" ]; then 
     clear
     return 0
  fi   
  
  d=0
  for i in "${realkeys[@]}"; do
    d=$((d+1))
    if [ "$d" == "$c" ]; then
      USExKEY=$i
      break
    fi
  done

  #echo $USExKEY
  #exit 1
  clear
  
  custom="${USExKEY/.pub/}"
  generic_exists="false"
  if [ ! -e "$custom" ]; then
     echo "Making Symbolic Link for key from private to base"
     ln -s "$custom.private" "$custom"
  else
     generic_exists="true"
  fi
  
  if [ -x /usr/bin/expect ]; then
     echo ''
     ssh_yes "$SSH_OPT $target" > /dev/null; ssh-copy-id -i $USExKEY $SSH_OPT $target 
  else
     echo "Please install the package called expect"
     pause
     ssh-copy-id -i $USExKEY $SSH_OPT $target
  fi
  run_success=$?
  
  if [ "$generic_exists" == "false" ] && [ -h "$custom" ]; then
     echo "Removing temp symbolic link that was just made..."
     rm "$custom"
  fi

  if [ ! "$run_success" -eq 0 ]; then
    exit 1
  fi      
}
