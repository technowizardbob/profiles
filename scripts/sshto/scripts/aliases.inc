add_aliases () { 
  clear
  echo "Compiling Bash Aliases...."
  if [ ! -f ${_MAIN_PATH_SSHTO}bin/bash_aliases.tar.gz ]; then
     ${_MAIN_PATH_SSHTO}scripts/compile_bash_aliases.sh
  else
     dialog --title "Choose an option" --yesno "Do you want to recompile aliases?" 10 50
# Check the return code of the dialog command to see which button was pressed
# Return code 0 means "recompile", return code 1 means "use existing"
case $? in
  0)
	clear
    echo "Recompiling..."
    ${_MAIN_PATH_SSHTO}scripts/compile_bash_aliases.sh
    ;;
  1)
    clear
    echo "Using existing aliases..."
    ;;
esac   		
  fi
  
  echo "Copying over tar file..."
  scp $SSH_OPT ${_MAIN_PATH_SSHTO}bin/bash_aliases.tar.gz $target:~
  echo "Copying over run_bash_alias_setup.sh"
  echo "chmod +x ~/run_bash_alias_setup.sh and then run it..."
  sleep 2
  scp $SSH_OPT ${_MAIN_PATH_SSHTO}scripts/run_bash_alias_setup.sh $target:~
}
