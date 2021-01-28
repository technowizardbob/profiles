HOSTS_FILE=/etc/hosts

if [ ! -d ~/.ssh ]; then
   #mkdir ~/.ssh # Commented out as it is done in gen_rsa_key.sh
   #chmod 700 ~/.ssh
   /opt/profiles/scripts/gen_rsa_key.sh
fi

defaults() {
   echo "Host mysite" >> ~/.ssh/config
   echo "    HostName YOURsiteHERE.com OR IP of computer" >> ~/.ssh/config
   echo "    Port $SSH_PORT" >> ~/.ssh/config
   echo "    User $DEFAULT_USER" >> ~/.ssh/config
   echo "    IdentityFile $USE_PRIVATE_KEY" >> ~/.ssh/config
}

choose_key() {
  local homes=~/.ssh/
  local pubs=$(find $homes -type f -iname "*.pub" 2> /dev/null)
  if [ -z $pubs ]; then
     USE_PRIVATE_KEY=${homes}${USER}_rsa.private
     return 0
  fi

  if [ -z $KEY ]; then
     akeys=()
     realkeys=()
     indexforkeys=()
  else
     non=${KEY/.pub/} 
     akeys=( "Default" "${non/$homes/}" )
     realkeys=( "${non}" )
     indexforkeys=( "Default" )
  fi

  IFSOLD=$IFS
  IFS=$'\n'
  
  local pubs_count=0
  local option_no=0
  for k in $pubs; do
    pubs_count=$((pubs_count+1))
    nonpub=${k/.pub/}
    if [ $k = "$KEY" ]; then 
       continue
    fi
       
    option_no=$((option_no+1))
    akeys+=( "$option_no" "${nonpub/$homes/}" )
    indexforkeys+=( "$option_no" )
    realkeys+=( "$nonpub" )
  done
  
   if [ $pubs_count -eq 1 ]; then
     USE_PRIVATE_KEY=$nonpub
     return 0
   elif [ $pubs_count -eq 0 ]; then
     USE_PRIVATE_KEY=~/.ssh/${USER}_rsa.private
     return 0
   fi
  
  IFS=$IFSOLD
  
  usekey=$(dialog --ok-label "Use this Key" --cancel-label "Back" --output-fd 1 \
                    --colors \
                    --menu "Select key:" 0 0 0 "${akeys[@]}")
  
  match=false
  c=0
  for no in "${indexforkeys[@]}"; do
    c=$((c+1))
    if [ "$usekey" = "$no" ]; then
       match=true
       break
    fi
  done
  
  if [ "$match" = false ]; then 
     USE_PRIVATE_KEY=~/.ssh/${USER}_rsa.private
     return 0
  fi   
  
  d=0
  for i in "${realkeys[@]}"; do
    d=$((d+1))
    if [ "$d" = "$c" ]; then
      if [ -r "${i}.private" ]; then
         USE_PRIVATE_KEY=${i}.private
      else
         USE_PRIVATE_KEY=$i
      fi
      return 0
    fi
  done

  USE_PRIVATE_KEY=~/.ssh/${USER}_rsa.private
}

default_ssh_port() {
    SSH_PORT=22
    new_port=$(dialog --ok-label "OK" --cancel-label "BACK" --output-fd 1 --max-input 5 \
                        --aspect 100 --colors --inputbox 'Change default SSH port#' 10 30 $SSH_PORT)
    SSH_PORT=${new_port:-$SSH_PORT}
}

default_username() {
    DEFAULT_USER=$USER
    new_user=$(dialog --ok-label "OK" --cancel-label "BACK" --output-fd 1 \
                        --aspect 100 --colors --inputbox 'Change default SSH USER' 10 30 $DEFAULT_USER)
    DEFAULT_USER=${new_user:-$DEFAULT_USER}
}

process_hosts_file() {
  echo "# Hosts to SSH into" > /tmp/localhosts_ssh
  echo "# For SSH config to auto populate please give your server" >> /tmp/localhosts_ssh
  echo "# -- hostnames the prefix of: ssh-" >> /tmp/localhosts_ssh
  echo "# Private/Remote Servers" > /tmp/localhosts_remotes
  echo "# Local-Hosts IPv4" > /tmp/localhosts_ip4
  echo "# Local-Hosts IPv6" > /tmp/localhosts_ip6
  comment=""

  IFSOLD=$IFS 
  IFS=$'\n' 
  for item in $(cat "$HOSTS_FILE"); do
    tipaddr=$(echo $item | awk '{print $1}')
    thostname=$(echo $item | awk '{print $2}')
    lcase=$(echo $thostname | tr '[A-Z]' '[a-z]')
    rhost=${lcase/ssh-/}
    rhost=${rhost/h-/}
    rhost=${rhost/host-/}
    if [ $(echo $tipaddr | awk -F. '{ printf("%d\n", $1); }') = "127" ]; then
       #echo "Skipped IPv4 Loopback"
       if [ -n "$comment" ]; then
          echo "$comment" >> /tmp/localhosts_ip4
          comment=""
       fi
       echo "$item" >> /tmp/localhosts_ip4
    elif [ "$(echo $tipaddr | grep -c "::")" -ge 1 ]; then
       #echo "Skipped IPv6 Loopback"
       if [ -n "$comment" ]; then
          echo "$comment" >> /tmp/localhosts_ip6
          comment=""
       fi
       echo "$item" >> /tmp/localhosts_ip6
    elif [ "$(echo $tipaddr | grep -c "^#")" -ge 1 ]; then
       #echo "Skipped Comment"
       if [ -n "$comment" ]; then
          comment+=$(printf "\n%s" "$item")
       elif [ $item != "# Hosts to SSH into" ] && \
            [ $item != "# For SSH config to auto populate please give your server" ] && \
            [ $item != "# -- hostnames the prefix of: ssh-" ] && \
            [ $item != "# Local-Hosts IPv4" ] && \
            [ $item != "# Local-Hosts IPv6" ] && \
            [ $item != "# Script will include Localhosts back in automatically" ] && \
            [ $item != "#" ]; then
          comment=$item
       fi
       continue
    elif [ "$(echo $lcase | grep -c "ssh-")" -eq 0 ]; then
       #echo "Skipped non ssh-hostname"
       if [ -n "$comment" ]; then
          echo "$comment" >> /tmp/localhosts_remotes
          comment=""
       fi
       remote_comment=$(echo $item | awk '{print $3 $4 $5 $6 $7 $8}')
       echo -e "$tipaddr\thost-$rhost  #WAS-$thostname  $remote_comment" >> /tmp/localhosts_remotes
       echo -e "$tipaddr\tssh-$rhost" >> /tmp/localhosts_ssh
    else
       #echo "Found SSH Host"
       if [ -n "$comment" ]; then
          echo "$comment" >> /tmp/localhosts_ssh
          comment=""
       fi
       echo -e "$tipaddr\tssh-$rhost" >> /tmp/localhosts_ssh
    fi
  done
  
  IFS=$IFSOLD
  
  cat /tmp/localhosts_ssh > /tmp/localhosts_main
  cat /tmp/localhosts_remotes >> /tmp/localhosts_main
  echo -e "\n#\n# Script will include Localhosts back in automatically" >> /tmp/localhosts_main
}

thostname=""
hostnames=()
deduper() {
   if [ ${#hostnames[@]} -eq 0 ]; then
      hostnames+=("$thostname")
      return 0
   fi
   local dup=false
   for x in "${hostnames[@]}"; do
     if [ "$x" = "$thostname" ]; then
        dup=true
        break
     fi   
   done
   if [ $dup = false ]; then
      hostnames+=("$thostname")
   fi
}

next_step() {
  if [ ! -d ~/.dotfile_backups ]; then
     mkdir ~/.dotfile_backups 2> /dev/null
  fi
  bknow=$(date +"%m_%d_%Y_%H_%M_%S")
  cp "$HOSTS_FILE" ~/.dotfile_backups/host${bknow} 2> /dev/null
  
  process_hosts_file
  
  echo -e "\n\nPlease add: Any NEW IP Addresses to Servers Hostname mappings from your new Hosts file."
  echo "As your /etc/hosts file will auto populate the SSH config to be more complete...."
  read -n 1 -s -r -p "Hit enter or press any key to continue:"  
  echo -e "\n\n"
  if [ -z $EDITOR ]; then
      nano /tmp/localhosts_main
  else
      $EDITOR /tmp/localhosts_main
  fi
  
  sed '/# Script will include Localhosts back in automatically/d' /tmp/localhosts_main > /tmp/tmpfile && mv -f /tmp/tmpfile /tmp/localhosts_main
}


findhosts() {

  IFSOLD=$IFS 
  IFS=$'\n' 

  local found_ssh=false
  for item in $(cat /etc/hosts); do
    tipaddr=$(echo $item | awk '{print $1}')
    thostname=$(echo $item | awk '{print $2}')
    lcase=$(echo $thostname | tr '[A-Z]' '[a-z]')
    
    if [ $(echo $tipaddr | awk -F. '{ printf("%d\n", $1); }') = "127" ]; then
       #echo "Skipped IPv4 Loopback"
       continue
    elif [ "$(echo $tipaddr | grep -c "::")" -ge 1 ]; then
       #echo "Skipped IPv6 Loopback"
       continue
    elif [ "$(echo $tipaddr | grep -c "^#")" -ge 1 ]; then
       #echo "Skipped Comment"
       continue
    elif [ "$(echo $lcase | grep -c "ssh-")" -eq 0 ]; then
       #echo "Skipped non ssh-hostname"
       continue
    else
       found_ssh=true
       break
    fi
  done
  if [ $found_ssh = true ]; then
     if [ -z $EDITOR ]; then
         nano "$HOSTS_FILE"
     else
         $EDITOR "$HOSTS_FILE"
     fi
     main=$HOSTS_FILE
  else 
     next_step
     main=/tmp/localhosts_main  
  fi
  
  for item in $(cat "$main"); do
    tipaddr=$(echo $item | awk '{print $1}')
    thostname=$(echo $item | awk '{print $2}')
    lcase=$(echo $thostname | tr '[A-Z]' '[a-z]')
    
    if [ $(echo $tipaddr | awk -F. '{ printf("%d\n", $1); }') = "127" ]; then
       #echo "Skipped IPv4 Loopback"
       continue
    elif [ "$(echo $tipaddr | grep -c "::")" -ge 1 ]; then
       #echo "Skipped IPv6 Loopback"
       continue
    elif [ "$(echo $tipaddr | grep -c "^#")" -ge 1 ]; then
       #echo "Skipped Comment"
       continue
    elif [ "$(echo $lcase | grep -c "ssh-")" -eq 0 ]; then
       #echo "Skipped non ssh-hostname"
       continue
    else
       deduper
    fi
  done
  
  IFS=$IFSOLD
  
  if [ $found_ssh = false ]; then
      cat /tmp/localhosts_ip4 >> /tmp/localhosts_main
      cat /tmp/localhosts_ip6 >> /tmp/localhosts_main
      echo -e "\n Original /etc/hosts file Backed up at: ~/.dotfile_backups/host${bknow}"
      echo "Updating Hosts File:"
      sudo rm /etc/hosts
      sudo mv /tmp/localhosts_main /etc/hosts
      rm -f /tmp/localhosts_*
  fi
}

if [ ! -r ~/.ssh/config ]; then
   choose_key
   default_ssh_port
   default_username
   
   clear
   
   if [ $(wc -l "$HOSTS_FILE" | awk -F. '{ printf("%d\n", $1); }') -gt 5000 ]; then
      echo -e "\n /etc/hosts file too big, bailing....!!"
      echo "Please split or remove old entries!!"
      read -n 1 -s -r -p "Hit enter or press any key to continue:"
      hostnames=()
   else
      findhosts
   fi
   
   echo "# Edit the following SSHTO config file:" > ~/.ssh/config
   echo "# What servers do you want to connect to?" >> ~/.ssh/config
   
   if [ ${#hostnames[@]} -eq 0 ]; then
      defaults
   else
      for h in "${hostnames[@]}"; do
          echo "Host ${h/ssh-/}" >> ~/.ssh/config
          echo "    HostName ${h}" >> ~/.ssh/config
          echo "    Port $SSH_PORT" >> ~/.ssh/config
          echo "    User $DEFAULT_USER" >> ~/.ssh/config
          echo "    IdentityFile $USE_PRIVATE_KEY" >> ~/.ssh/config
      done
   fi
   echo "Host github #ignore" >> ~/.ssh/config
   echo "    HostName github.com" >> ~/.ssh/config
   echo "    Port 22" >> ~/.ssh/config
   echo "    User git" >> ~/.ssh/config
   echo "    IdentityFile $USE_PRIVATE_KEY" >> ~/.ssh/config
   echo "#Host Group #My Work Server's#" >> ~/.ssh/config
   chmod 644 ~/.ssh/config
   if [ -z $EDITOR ]; then
      nano ~/.ssh/config
   else
      $EDITOR  ~/.ssh/config
   fi
fi
