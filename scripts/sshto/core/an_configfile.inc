HOSTS_FILE=/etc/hosts
split="1" # Default of no Split!!!

if [ ! -d ~/.ssh ]; then
   #mkdir ~/.ssh # Commented out as it is done in gen_rsa_key.sh
   #chmod 700 ~/.ssh
   /opt/profiles/scripts/gen_rsa_key.sh
fi

defaults() {
   echo "Host s-mysite" >> ~/.ssh/config
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
  
  IFS=$IFSOLD
  
   if [ $pubs_count -eq 1 ]; then
     USE_PRIVATE_KEY=$nonpub
     return 0
   elif [ $pubs_count -eq 0 ]; then
     USE_PRIVATE_KEY=~/.ssh/${USER}_rsa.private
     return 0
   fi
  
  if [ ${#akeys[@]} -eq 0 ]; then
      USE_PRIVATE_KEY=~/.ssh/${USER}_rsa.private
      return 0
  fi
  
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

split_hosts_file() {
  echo "# I would suggest the pre-fix of h- or host- to avoid issues with ssh..." > /tmp/localhosts_remotes
  echo "# Private/Remote Servers" > /tmp/localhosts_remotes
  echo "# Local-Hosts IPv4" > /tmp/localhosts_ip4
  echo "# Local-Hosts IPv6" > /tmp/localhosts_ip6
  comment=""

  IFSOLD=$IFS 
  IFS=$'\n' 
  for item in $(cat "$HOSTS_FILE"); do
    tipaddr=$(echo $item | awk '{print $1}')
    thostname=$(echo $item | awk '{print $2}')
    #lcase=$(echo $thostname | tr '[A-Z]' '[a-z]')
    #rhost=${lcase/ssh-/}
    #rhost=${rhost/h-/}
    #rhost=${rhost/host-/}
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
       
       if [ $item != "# Private/Remote Servers" && \
            [ $item != "# Local-Hosts IPv4" ] && \
            [ $item != "# Local-Hosts IPv6" ] && \
            [ $item != "# Script will include Localhosts back in automatically" ] && \
            [ $item != "#" ]; then
               if [ -n "$comment" ]; then
                  comment+=$(printf "\n%s" "$item")  
               else   
                  comment=$item
               fi
       fi
       continue
    else
       #echo "Found Private/Remote Host"
       if [ -n "$comment" ]; then
          echo "$comment" >> /tmp/localhosts_remotes
          comment=""
       fi
       echo "$item" >> /tmp/localhosts_remotes
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

ask_to_split() {
    dialog --output-fd 1 --title "Split Host File" \
       --backtitle "Hosts file too large, temporary..split it?" \
       --yesno "Local Hosts will be placed at bottom of host file." 7 60
    
    split=$?
    clear
}

admin_step() {
  
  if [ $(wc -l "$HOSTS_FILE" | awk -F. '{ printf("%d\n", $1); }') -gt 500 ]; then
     ask_to_split
  fi 
  
  echo "Updating Hosts"
  if [ ! -d ~/.dotfile_backups ]; then
     mkdir ~/.dotfile_backups 2> /dev/null
  fi
  bknow=$(date +"%m_%d_%Y_%H_%M_%S")
  cp "$HOSTS_FILE" ~/.dotfile_backups/host${bknow} 2> /dev/null

  if [ "$split" = "0" ]; then
    split_hosts_file
  else
    if [ -x /usr/bin/tee ] || [ -x /bin/tee ]; then
       echo -e "# Please add all your SSH Servers to this list:"  | cat - "$HOSTS_FILE" | sudo tee "$HOSTS_FILE"
    fi

    if [ -z $EDITOR ]; then
       sudo nano "$HOSTS_FILE"
    else
       sudo $EDITOR "$HOSTS_FILE"
    fi
    sed '/# Please add all your SSH Servers to this list:/d' "$HOSTS_FILE" > /tmp/localhosts_o && sudo mv -f /tmp/localhosts_o "$HOSTS_FILE"
    return 1
  fi
    
  if [ -z $EDITOR ]; then
      nano /tmp/localhosts_main
  else
      $EDITOR /tmp/localhosts_main
  fi
  
  sed '/# Script will include Localhosts back in automatically/d' /tmp/localhosts_main > /tmp/tmpfile && mv -f /tmp/tmpfile /tmp/localhosts_main
}

admin_check() {
   if [ $UID -eq 0 ]; then
      admin_step
   else
      sudoers_power=$(groups $USER | grep "sudo")
      admin_power=$(groups $USER | grep "admin")
      wheel_power=$(groups $USER | grep "wheel")
      if [ -n "sudoers_power" ] || [ -n "admin_power" ] || [ -n "wheel_power" ]; then
         admin_step
      fi
    fi
}

clean_up_split() {
  if [ "$split" = "0" ]; then
      cat /tmp/localhosts_ip4 >> /tmp/localhosts_main
      cat /tmp/localhosts_ip6 >> /tmp/localhosts_main
      echo -e "\n Original $HOSTS_FILE file Backed up at: ~/.dotfile_backups/host${bknow}"
      echo "Cleaning up hosts file...."
      sudo mv -f $HOSTS_FILE "${HOSTS_FILE}_old"
      sudo mv /tmp/localhosts_main $HOSTS_FILE
      sudo chown root:root $HOSTS_FILE
      sudo chmod 644 $HOSTS_FILE
      rm -f /tmp/localhosts_*
  fi
}

findhosts() {
  
  admin_check
   
  if [ "$split" = "0" ]; then
     read_hosts=/tmp/localhosts_main
  else
     read_hosts=$HOSTS_FILE
  fi
  
  IFSOLD=$IFS 
  IFS=$'\n' 
  
  for item in $(cat $read_hosts); do
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
    else
       deduper
    fi
  done
  
  IFS=$IFSOLD

  clean_up_split
  
}

if [ ! -r ~/.ssh/config ]; then
   choose_key
   default_ssh_port
   default_username
   clear
   findhosts
   
   # Begin Dummy Config   
echo "
Include ~/.ssh/configs_*.conf

# Edit the following SSHTO config file:
# To avoid hostname collisions, I suggest to name Hosts with an prefix of: s-
# What servers do you want to connect to?

#Host Group #My Work Server's#
" > ~/.ssh/config
   
   if [ ${#hostnames[@]} -eq 0 ]; then
      defaults
   else
      for h in "${hostnames[@]}"; do
        ch=${h/host-/}
        ch=${ch/h-/}
        ch=${ch/s-/}
        ch=${ch/ssh-/}
          echo "Host s-${ch}" >> ~/.ssh/config
          echo "    HostName ${h}" >> ~/.ssh/config
          echo "    Port $SSH_PORT" >> ~/.ssh/config
          echo "    User $DEFAULT_USER" >> ~/.ssh/config
          echo "    IdentityFile $USE_PRIVATE_KEY" >> ~/.ssh/config
      done
   fi
   echo "
Host github #ignore
    HostName github.com
    Port 22
    User git
    IdentityFile $USE_PRIVATE_KEY

# ---  default for all NOT Defined hosts..! ---
Host *
     ForwardAgent no
     ForwardX11 no
     ForwardX11Trusted yes
     User root
     Port 22
     Protocol 2
     ServerAliveInterval 60
     ServerAliveCountMax 30
" >> ~/.ssh/config

echo "
#Host Group #Proxies's#
# Forward all local port 3128 traffic to port 3128 on the remote vps1.cyberciti.biz server
# $ ssh -f -N  proxyus
Host proxyus #ignore
    HostName vps1.cyberciti.biz
    User breakfree
    IdentityFile ~/.ssh/vps1.cyberciti.biz.key
    LocalForward 3128 127.0.0.1:3128     
" >> ~/.ssh/configs_proxy.conf

   chmod 644 ~/.ssh/config
   chmod 644 ~/.ssh/configs_proxy.conf
   if [ -z $EDITOR ]; then
      nano ~/.ssh/config
   else
      $EDITOR  ~/.ssh/config
   fi
fi
