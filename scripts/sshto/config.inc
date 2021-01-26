REMOTE=5901  # Remote port for tunneling.
LOCAL=5901  # Local  port for tunneling.
GUEST=$USER  # Alternative username to login with.
DEST='~'     # Destination folder on target server to download\upload files.
TIME=60      # Timer for tunneling command. Tunnel will be closed after 60 seconds, but it will stay open if used.
if [ -z $EDITOR ]; then 
   EDITOR=nano  # Editor nano or vim
fi
SSH_OPT=     # SSH Options

# SSH key to use (Add my ssh key to host).
if [ -r ~/.ssh/${USER}_rsa.pub ]; then
   KEY=~/.ssh/${USER}_rsa.pub
elif [ -r ~/.ssh/${USER}.pub ]; then
   KEY=~/.ssh/${USER}.pub
elif [ -r ~/.ssh/id_rsa.pub ]; then
   KEY=~/.ssh/id_rsa.pub 
else
   KEY=$(ls ~/.ssh/*.pub| head -1)
fi
#echo $KEY
