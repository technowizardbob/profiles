list_files() { clear; ssh $SSH_OPT $target "ls -la"; pause; }
free_mem() { clear; ssh $SSH_OPT $target "free -h"; pause; }
free_inodes() { clear; ssh $SSH_OPT $target "df -ih"; pause; }
disk_space() { clear; ssh $SSH_OPT $target "df -h"; pause; }
