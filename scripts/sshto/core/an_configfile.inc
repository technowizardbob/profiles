HOSTS_FILE=/etc/hosts
split="1" # Default of no Split!!!

pkey() {
  if [ -f "$PK" ]; then
      USE_PRIVATE_KEY=$PK
  elif [ -f "${PK}.private" ]; then
      USE_PRIVATE_KEY=${PK}.private
  else
      USE_PRIVATE_KEY=$HPATH/.ssh/id_rsa
  fi
}

choose_key() {
  local homes=$HPATH/.ssh/
  local pubs=$(find "$homes" -type f -iname "*.pub" 2> /dev/null)
  if [ -z "$pubs" ]; then
     PK=${homes}${USER}
     pkey
     return 0
  fi

  nonpub=""
  akeys=()
  realkeys=()
  indexforkeys=()

  IFSOLD=$IFS
  IFS=$'\n'
  
  local pubs_count=0
  local option_no=0
  for k in $pubs; do
    pubs_count=$((pubs_count+1))
    nonpub=${k/.pub/}
    option_no=$((option_no+1))
    akeys+=( "$option_no" "${nonpub/$homes/}" )
    indexforkeys+=( "$option_no" )	
    realkeys+=( "$nonpub" )
  done
  
  IFS=$IFSOLD
  
   if [ "$pubs_count" -eq "1" ]; then
     PK=$nonpub
     pkey
     return 0
   elif [ "$pubs_count" -eq "0" ]; then
     PK=$HPATH/.ssh/${USER}
     pkey
     return 0
   fi
  
  if [ "${#akeys[@]}" -eq "0" ]; then
      PK=$HPATH/.ssh/${USER}
      pkey
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
     PK=$HPATH/.ssh/${USER}
     pkey
     return 0
  fi   
  
  d=0
  for i in "${realkeys[@]}"; do
    d=$((d+1))
    if [ "$d" = "$c" ]; then
      PK=$i
      pkey
      return 0
    fi
  done

  PK=$HPATH/.ssh/${USER}
  pkey
}

ask_to_edit_hosts() {
    dialog --output-fd 1 --title "Edit Host File" \
       --backtitle "Add servers to your /etc/hosts file as SUDOer?" \
       --yesno "Would you like to add any servers as SUDO user?" 7 60   
    EDIT_HOSTS=$?
    clear
}

default_ssh_port() {
    SSH_PORT=22
    new_port=$(dialog --ok-label "OK" --cancel-label "BACK" --output-fd 1 --max-input 5 \
                        --aspect 100 --colors --inputbox 'Change default SSH port#' 10 30 "$SSH_PORT")
    SSH_PORT=${new_port:-$SSH_PORT}
}

default_username() {
    DEFAULT_USER=$USER
    new_user=$(dialog --ok-label "OK" --cancel-label "BACK" --output-fd 1 \
                        --aspect 100 --colors --inputbox 'Change default SSH USER' 10 30 "$DEFAULT_USER")
    DEFAULT_USER=${new_user:-$DEFAULT_USER}
}

split_hosts_file() {
  echo "# Private/Remote Servers" > /tmp/localhosts_remotes
  echo "# Local-Hosts IPv4" > /tmp/localhosts_ip4
  echo "# Local-Hosts IPv6" > /tmp/localhosts_ip6
  comment=""

  IFSOLD=$IFS 
  IFS=$'\n' 
  for item in $(cat "$HOSTS_FILE"); do
    tipaddr=$(echo "$item" | awk '{print $1}')
    thostname=$(echo "$item" | awk '{print $2}')
    #lcase=$(echo "$thostname" | tr '[A-Z]' '[a-z]')
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
    elif [ $(echo $tipaddr | grep -c "::") -ge 1 ]; then
       #echo "Skipped IPv6 Loopback"
       if [ -n "$comment" ]; then
          echo "$comment" >> /tmp/localhosts_ip6
          comment=""
       fi
       echo "$item" >> /tmp/localhosts_ip6
    elif [ $(echo $tipaddr | grep -c "^#") -ge 1 ]; then
       #echo "Skipped Comment"
       
       if [ "$item" != "# Private/Remote Servers" ] && \
            [ "$item" != "# Local-Hosts IPv4" ] && \
            [ "$item" != "# Local-Hosts IPv6" ] && \
            [ "$item" != "# Script will include Localhosts back in automatically" ] && \
            [ "$item" != "#" ]; then
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

  ask_to_edit_hosts
  if [ "$EDIT_HOSTS" = "0" ]; then 
     echo "Editing Hosts file..."
  else
     return 0 
  fi
  
  if [ $(wc -l "$HOSTS_FILE" | awk -F. '{ printf("%d\n", $1); }') -gt 500 ]; then
     ask_to_split
  fi 
  
  echo "Updating Hosts"
  if [ ! -d "$HPATH/.dotfile_backups" ]; then
     mkdir "$HPATH/.dotfile_backups" 2> /dev/null
  fi
  local bknow=$(date +"%m_%d_%Y_%H_%M_%S")
  cp "$HOSTS_FILE" "$HPATH/.dotfile_backups/host${bknow}" 2> /dev/null

  if [ "$split" = "0" ]; then
    split_hosts_file
  else
    if [ -x /usr/bin/tee ] || [ -x /bin/tee ]; then
       echo -e "# Please add all your SSH Servers to this list:"  | cat - "$HOSTS_FILE" | sudo tee "$HOSTS_FILE"
    fi

    if [ -z "$EDITOR" ]; then
       sudo nano "$HOSTS_FILE"
    else
       sudo "$EDITOR" "$HOSTS_FILE"
    fi
    sudo sed -i '/# Please add all your SSH Servers to this list:/d' "$HOSTS_FILE"
    return 1
  fi
    
  if [ -z "$EDITOR" ]; then
      nano /tmp/localhosts_main
  else
      "$EDITOR" /tmp/localhosts_main
  fi
  
  sed -i '/# Script will include Localhosts back in automatically/d' /tmp/localhosts_main
}

admin_check() {
   if [ $UID -eq 0 ]; then
      admin_step
   else
      sudoers_power=$(groups "$USER" | grep " sudo")
      admin_power=$(groups "$USER" | grep " admin")
      wheel_power=$(groups "$USER" | grep " wheel")
      if [ -n "$sudoers_power" ] || [ -n "$admin_power" ] || [ -n "$wheel_power" ]; then
         admin_step
      fi
    fi
}

clean_up_split() {
  if [ "$split" = "0" ]; then
      cat /tmp/localhosts_ip4 >> /tmp/localhosts_main
      cat /tmp/localhosts_ip6 >> /tmp/localhosts_main
      echo -e "\n Original $HOSTS_FILE file Backed up at: $HPATH/.dotfile_backups/host${bknow}"
      echo "Cleaning up hosts file...."
      sudo mv -f "$HOSTS_FILE" "${HOSTS_FILE}_old"
      sudo mv /tmp/localhosts_main "$HOSTS_FILE"
      sudo chown root:root "$HOSTS_FILE"
      sudo chmod 644 "$HOSTS_FILE"
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
  
  for item in $(cat "$read_hosts"); do
    tipaddr=$(echo "$item" | awk '{print $1}')
    thostname=$(echo "$item" | awk '{print $2}')
    lcase=$(echo "$thostname" | tr '[A-Z]' '[a-z]')
    
    if [ "$(echo $tipaddr | awk -F. '{ printf("%d\n", $1); }')" = "127" ]; then
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

edit_configs() {
  IFSOLD=$IFS
  IFS=$'\n'

  local aconfig=()
  local cfgs=$(ls $HPATH/.ssh/config*)
  local realconfig=()
  local realindex=()
  local p=""
  local r=""
  local cdd
  for cdd in $cfgs; do
     realconfig+=( "$cdd" )
     p=$HPATH/.ssh/
     r=${cdd/$p/}
     de=${r/configs_/}
     de=${de/.conf/}
     realindex+=( "$de" )
     aconfig+=( "$de" "$r" )
  done
  
  if [ "${#aconfig[@]}" -eq "0" ]; then
     return 1
  fi   
 
  editme=$(dialog --ok-label "Edit this config" --cancel-label "Back" --output-fd 1 \
                    --colors \
                    --menu "Select SSH file:" 0 0 0 "${aconfig[@]}")

  local match=false
  local c=0
  local no
  for no in "${realindex[@]}"; do
    c=$((c+1))
    # echo "$no"
    if [ "$editme" = "$no" ]; then
       match=true
       break
    fi
  done
  
  if [ "$match" = false ]; then 
     return 0
  fi   
  
  local d=0
  local i
  for i in "${realconfig[@]}"; do
    d=$((d+1))
    if [ "$d" = "$c" ]; then
        "$EDITOR" "$i"
        break
    fi
  done

  IFS=$IFSOLD
}

if [ ! -r "$HPATH/.ssh/config" ]; then
   choose_key
   default_ssh_port
   default_username
   clear
   findhosts

   prefix=""
   #prefix_num=$(dialog --output-fd 1 --menu "SSH name prefixes:" 0 0 0 1 "None" 2 "s-" 3 "ssh-")
   #case "$prefix_num" in
   #   '2') prefix="s-";; 
   #   '3') prefix="ssh-";;
   #   *) prefix="";;
   #esac
   
   # Begin Dummy Configs   
echo "Include $HPATH/.ssh/configs_*.conf

# Edit the following SSHTO config file:
# What servers do you want to connect to?" > "$HPATH/.ssh/config"

if [ -r "$HPATH/.ssh/configs_work.conf" ]; then
   bknow=$(date +"%m_%d_%Y_%H_%M_%S")
   mv "$HPATH/.ssh/configs_work.conf" "$HPATH/.ssh/bk_configs_work${bknow}.old"  2> /dev/null
fi
   
   echo "#Host Group #My Work Server's#" > "$HPATH/.ssh/configs_work.conf"
   
   if [ "${#hostnames[@]}" -eq "0" ]; then
    echo "Host ${prefix}mysite
    HostName YOURsiteHERE.com OR IP of computer
    Port $SSH_PORT
    User $DEFAULT_USER
    IdentityFile $USE_PRIVATE_KEY" >> "$HPATH/.ssh/configs_work.conf"
   else
      for h in "${hostnames[@]}"; do
        ch=${h/host-/}
        ch=${ch/h-/}
        ch=${ch/s-/}
        ch=${ch/ssh-/}
echo "Host ${prefix}${ch}
    HostName ${h}
    Port $SSH_PORT
    User $DEFAULT_USER
    IdentityFile $USE_PRIVATE_KEY" >> "$HPATH/.ssh/configs_work.conf"
    
      done
   fi
   
   echo "Host github #ignore
    HostName github.com
    Port 22
    User git
    IdentityFile $USE_PRIVATE_KEY

# ---  default for all NOT Defined hosts..! ---
Host *
    Protocol 2
    HostKeyAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256,ssh-rsa
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group16-sha512
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
    StrictHostKeyChecking ask
    VerifyHostKeyDNS ask
    User root
    Port 22
    ServerAliveInterval 300
    ServerAliveCountMax 3
    ForwardAgent no
    ForwardX11 no
    ForwardX11Trusted no
    PermitLocalCommand no
    HashKnownHosts yes
    TCPKeepAlive yes
    SendEnv LANG LC_*
" >> "$HPATH/.ssh/config"

if [ ! -r "$HPATH/.ssh/configs_home.conf" ]; then
   echo "#Host Group #My Home Lab#   
Host ${prefix}lab #ignore
    HostName lab1
    Port $SSH_PORT
    User $DEFAULT_USER
    IdentityFile $USE_PRIVATE_KEY" > "$HPATH/.ssh/configs_home.conf"
fi

if [ ! -r "$HPATH/.ssh/EXAMPLEconfigs_proxy.conf" ]; then
echo "#Host Group #Proxies's#
# Forward all local port 3128 traffic to port 3128 on the remote vps1.cyberciti.biz server
# $ ssh -f -N  proxyus
Host proxyus #ignore
    HostName vps1.cyberciti.biz
    User breakfree
    IdentityFile $HPATH/.ssh/vps1.cyberciti.biz.key
    LocalForward 3128 127.0.0.1:3128" > "$HPATH/.ssh/EXAMPLEconfigs_proxy.conf"
fi

   chmod 644 "$HPATH/.ssh/config"
   chmod 644 "$HPATH/.ssh/configs_work.conf"
   chmod 644 "$HPATH/.ssh/configs_home.conf"
   chmod 644 "$HPATH/.ssh/EXAMPLEconfigs_proxy.conf"

   edit_configs

fi
