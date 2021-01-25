if [ ! -d ~/.ssh ]; then
   mkdir ~/.ssh
   chmod 700 ~/.ssh
   /opt/profiles/scripts/gen_rsa_key.sh
fi
if [ ! -r ~/.ssh/config ]; then
   echo "# Edit the following SSHTO config file:" > ~/.ssh/config
   echo "# What sites do you want to connect to?" >> ~/.ssh/config
   echo "Host mysite" >> ~/.ssh/config
   echo "    HostName YOURsiteHERE.com OR IP of computer" >> ~/.ssh/config
   echo "    Port 2992" >> ~/.ssh/config
   echo "    User $USER" >> ~/.ssh/config
   echo "    IdentityFile ~/.ssh/${USER}_rsa.private" >> ~/.ssh/config

   echo "Host github" >> ~/.ssh/config
   echo "    HostName github.com" >> ~/.ssh/config
   echo "    Port 22" >> ~/.ssh/config
   echo "    User git" >> ~/.ssh/config
   echo "    IdentityFile ~/.ssh/${USER}_rsa.private" >> ~/.ssh/config

   chmod 644 ~/.ssh/config
   nano ~/.ssh/config
fi
