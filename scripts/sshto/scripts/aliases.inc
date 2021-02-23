add_aliases () { 
  clear;
  if [ ! -f /opt/profiles/scripts/sshto/bin/bash_aliases.tar.gz ]; then
     /opt/profiles/scripts/sshto/scripts/compile_bash_aliases.sh
  fi
  scp $SSH_OPT /opt/profiles/scripts/sshto/bin/bash_aliases.tar.gz $target:~
  echo -e "#!/bin/bash \nsudo mkdir -p /opt/profiles \ncd /opt/profiles \nsudo tar -xvzf ~/bash_aliases.tar.gz" > /opt/profiles/scripts/sshto/bin/run_bash_alias_setup.sh
  echo -e "\nrm ~/.git_bash_prompt \nmv ~/.bashrc ~/.bashrc_old \nmv ~/.bash_aliases ~/.bash_aliases_old" >> /opt/profiles/scripts/sshto/bin/run_bash_alias_setup.sh
  echo -e "\nln -s /opt/profiles/.bashrc ~/.bashrc \nln -s /opt/profiles/.git_bash_prompt ~/.git_bash_prompt" >> /opt/profiles/scripts/sshto/bin/run_bash_alias_setup.sh
  echo -e "\nln -s /opt/profiles/.bash_aliases ~/.bash_aliases" >> /opt/profiles/scripts/sshto/bin/run_bash_alias_setup.sh
  scp $SSH_OPT /opt/profiles/scripts/sshto/bin/run_bash_alias_setup.sh $target:~
}
