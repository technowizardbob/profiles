if [ ! -d ~/.ssh ]; then
   mkdir ~/.ssh
   chmod 700 ~/.ssh
fi
if [ ! -r ~/.ssh/config ]; then
   echo "Host mysite" > ~/.ssh/config
   echo "    HostName site.com" >> ~/.ssh/config
   echo "    Port 2992" >> ~/.ssh/config
   echo "    User $USER" >> ~/.ssh/config
   echo "    IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config
   chmod 644 ~/.ssh/config
   nano ~/.ssh/config
fi
   
