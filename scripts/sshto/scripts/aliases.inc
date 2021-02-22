add_aliases () { 
  clear;
  if [ ! -f /opt/profiles/scripts/sshto/bin/.bash_aliases ]; then
     /opt/profiles/scripts/sshto/scripts/compile_bash_aliases.sh
  fi
  scp $SSH_OPT /opt/profiles/scripts/sshto/bin/.bash_aliases $target:~
}
