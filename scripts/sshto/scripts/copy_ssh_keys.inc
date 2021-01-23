add_sshkey() { clear; ssh_yes "$SSH_OPT $target" > /dev/null; ssh-copy-id -i $KEY $SSH_OPT $target; }
