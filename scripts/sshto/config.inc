REMOTE=5901  # Remote port for tunneling.
LOCAL=5901   # Local  port for tunneling.
GUEST=$USER  # Alternative username to login with.
DEST="/home/$USER"     # Destination folder on target server to download\upload files.
TIME=60      # Timer for tunneling command. Tunnel will be closed after 60 seconds, but it will stay open if used.
LSEXIT=false # Perform ls on exit true|false.
home=$PWD    # Destination folder on local server to download\upload files and sshfs mount.
sshdir=~/.ssh # Ssh configfiles folder
knwhosts="$sshdir"/known_hosts # Path to known_hosts file
sshfsopt=  	 # Sshfs options (-o allow_other) [[would allow ALL users access]]
SSH_OPT=     # SSH Options

if [ -z "$EDITOR" ]; then 
   EDITOR=nano  # Editor nano or vim
fi

if [ -d "$HOME" ]; then
   HPATH=$HOME
elif [ -d "/home/$USER" ]; then
   HPATH=/home/$USER
else
   echo "Unable to Find user HOME folder!!!!"
   exit 1
fi

# SSH key to use (Add my ssh key to host).
if [ ! -d "$HPATH/.ssh" ]; then
   echo "Let's setup SSH...."
elif [ -r "$HPATH/.ssh/${USER}_rsa.pub" ]; then
   KEY=$HPATH/.ssh/${USER}_rsa.pub
elif [ -r "$HPATH/.ssh/${USER}.pub" ]; then
   KEY=$HPATH/.ssh/${USER}.pub
elif [ -r "$HPATH/.ssh/id_rsa.pub" ]; then
   KEY=$HPATH/.ssh/id_rsa.pub 
else
   KEY=$(ls $HPATH/.ssh/*.pub 2> /dev/null | head -1)
fi
#echo $KEY

# Save selected context for current user
tmpfile=/tmp/sshtorc-${USER}
