HOSTS_FILE=/etc/hosts
TEMP_HOSTS=/tmp/hf

if [ ! -d ~/.ssh ]; then
   #mkdir ~/.ssh # Commented out as it is done in gen_rsa_key.sh
   #chmod 700 ~/.ssh
   /opt/profiles/scripts/gen_rsa_key.sh
fi

defaults() {
   echo "Host mysite" >> ~/.ssh/config
   echo "    HostName YOURsiteHERE.com OR IP of computer" >> ~/.ssh/config
   echo "    Port 2992" >> ~/.ssh/config
   echo "    User $USER" >> ~/.ssh/config
   echo "    IdentityFile ~/.ssh/${USER}_rsa.private" >> ~/.ssh/config
}

findhosts() {
  cp "$HOSTS_FILE" "$TEMP_HOSTS"

  hostnames=()

  IFSOLD=$IFS 
  IFS=$'\n' 

  for item in $(cat "$TEMP_HOSTS")
  do
    tipaddr=$(echo $item | awk '{print $1}')
    thostname=$(echo $item | awk '{print $2}')
    #lcase=$(echo $thostname | tr '[A-Z]' '[a-z]')
    
    if [ $(echo $tipaddr | awk -F. '{ printf("%d\n", $1); }') = "127" ]; then
       #echo "Skipped IPv4 Loopback"
       continue
    elif [ "$(echo $tipaddr | grep -c "::")" -ge 1 ] || [ "$(echo $tipaddr | grep -c "^#")" -ge 1 ] ; then
       #echo "Skipped IPv6 Loopback"
       continue
    else
       #echo $item
       #echo $thostname
       hostnames+=("$thostname")
    fi
  done
  rm "$TEMP_HOSTS"
  IFS=$IFSOLD
}

if [ ! -r ~/.ssh/config ]; then
   echo "# Edit the following SSHTO config file:" > ~/.ssh/config
   echo "# What servers do you want to connect to?" >> ~/.ssh/config

   findhosts
   if [ ${#hostnames[@]} -eq 0 ]; then
      defaults
   else
      for h in "${hostnames[@]}"
      do
          echo "Host _${h}" >> ~/.ssh/config
          echo "    HostName ${h}" >> ~/.ssh/config
          echo "    Port 2992" >> ~/.ssh/config
          echo "    User $USER" >> ~/.ssh/config
          echo "    IdentityFile ~/.ssh/${USER}_rsa.private" >> ~/.ssh/config
      done
   fi
   echo "Host github #ignore" >> ~/.ssh/config
   echo "    HostName github.com" >> ~/.ssh/config
   echo "    Port 22" >> ~/.ssh/config
   echo "    User git" >> ~/.ssh/config
   echo "    IdentityFile ~/.ssh/${USER}_rsa.private" >> ~/.ssh/config
   echo "#Host Group #My Work Server's#" >> ~/.ssh/config
   chmod 644 ~/.ssh/config
   nano ~/.ssh/config
fi
