add_aliases () { 
  clear
  echo "Compiling Bash Aliases...."
  if [ ! -f /opt/profiles/scripts/sshto/bin/bash_aliases.tar.gz ]; then
     /opt/profiles/scripts/sshto/scripts/compile_bash_aliases.sh
  fi
  echo "Copying over tar file..."
  scp $SSH_OPT /opt/profiles/scripts/sshto/bin/bash_aliases.tar.gz $target:~
  echo "Copying over run_bash_alias_setup.sh"
  echo "chmod +x ~/run_bash_alias_setup.sh and then run it..."
  scp $SSH_OPT /opt/profiles/scripts/sshto/scripts/run_bash_alias_setup.sh $target:~
}
