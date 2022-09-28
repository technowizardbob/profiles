add_aliases () { 
  clear
  echo "Compiling Bash Aliases...."
  if [ ! -f ${_MAIN_PATH_SSHTO}bin/bash_aliases.tar.gz ]; then
     ${_MAIN_PATH_SSHTO}scripts/compile_bash_aliases.sh
  fi
  echo "Copying over tar file..."
  scp $SSH_OPT ${_MAIN_PATH_SSHTO}bin/bash_aliases.tar.gz $target:~
  echo "Copying over run_bash_alias_setup.sh"
  echo "chmod +x ~/run_bash_alias_setup.sh and then run it..."
  scp $SSH_OPT ${_MAIN_PATH_SSHTO}scripts/run_bash_alias_setup.sh $target:~
}
