REMOTE=5901  # Remote port for tunneling.
LOCAL=5901  # Local  port for tunneling.
GUEST=$USER  # Alternative username to login with.
DEST='~'     # Destination folder on target server to download\upload files.
TIME=60      # Timer for tunneling command. Tunnel will be closed after 60 seconds, but it will stay open if used.
EDITOR=nano  # Editor nano or vim
SSH_OPT=     # SSH Options
KEY=~/.ssh/id_rsa.pub # SSH key to use (Add my ssh key to host).
