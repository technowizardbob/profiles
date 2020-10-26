#!/bin/bash
if ([ -f /home/$USER/.old_bash_aliases ] || [ -f /home/$USER/.old_bashrc ] || [ -f /home/$USER/.old_profile ] || [ -f /home/$USER/.old_git_svn_bash_prompt ]); 
then 
	rm .old_*
fi
if [ -f /home/$USER/.bash_aliases ]; then 
	mv /home/$USER/.bash_aliases /home/$USER/.old_bash_aliases
fi
if [ -f /home/$USER/.bashrc ]; then 
	mv /home/$USER/.bashrc /home/$USER/.old_bashrc
fi
if [ -f /home/$USER/.profile ]; then
	mv /home/$USER/.profile /home/$USER/.old_profile
fi
if [ -f /home/$USER/.git_bash_prompt ]; then 
	mv /home/$USER/.git_bash_prompt /home/$USER/.old_git_bash_prompt
fi
if ([ -d aliases ] && [ -f .bash_aliases ]); then
	echo "Making Sym Links from current install location"
	ln -s "$(pwd -P)"/.bash_aliases /home/$USER/
	ln -s "$(pwd -P)"/.bashrc /home/$USER/
	ln -s "$(pwd -P)"/.profile /home/$USER/
	ln -s "$(pwd -P)"/.git_bash_prompt /home/$USER/
else
  if ([ -d /opt/profiles/aliases ] && [ -f /opt/profiles/.bash_aliases ]); then
    echo "Making Sym Links from /opt/profiles install location"
	ln -s /opt/profiles/.bash_aliases /home/$USER/
	ln -s /opt/profiles/.bashrc /home/$USER/
	ln -s /opt/profiles/.profile /home/$USER/
	ln -s /opt/profiles/.git_bash_prompt /home/$USER/
  fi
fi
echo -e "\n"
echo "Installed to local user ${USER}."
echo "For listing of all commands Type: commands"
echo -e "\n"
echo "See a list of commands Type: command"
echo "To read the command file type command followed by the filename without the file extesion."
echo -e "\n"
echo "Example: command web"
echo -e "\n"
echo "Ex2: command git"
echo "Ex3: command apt_get"
echo "Ex4: command docker"
echo "Ex5: command folders"
