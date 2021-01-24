#!/bin/bash
if [ "$EUID" -eq 0 ]; then
	echo -e "\nPlease backup and make sym-links your self for the root account, as I do not want to make a admin mad.\n"
	echo "ln -s /pathHere/{.bashrc,.bash_aliases,.profile,.git_bash_prompt} /root/"
	echo -e "\nAlso, for dotfiles folder....\n"
	echo -e "\nAlso, if you want all new users to have the same aliases....link to /etc/skel/ \n"
	exit 1
fi
if ([ -f /home/$USER/.old_a_bash_aliases ] || [ -f /home/$USER/.old_a_bashrc ] || \
    [ -f /home/$USER/.old_a_profile ] || [ -f /home/$USER/.old_a_git_svn_bash_prompt ] || \
    [ -f /home/$USER/.old_a_gitconfig ] || [ -f /home/$USER/.ran_profiles_once ]); then 
    	echo -e "Already run once for this user!!"
	exit 1
fi
if [ -f /home/$USER/.bash_aliases ]; then 
	mv /home/$USER/.bash_aliases /home/$USER/.old_a_bash_aliases
fi
if [ -f /home/$USER/.bashrc ]; then 
	mv /home/$USER/.bashrc /home/$USER/.old_a_bashrc
fi
if [ -f /home/$USER/.profile ]; then
	mv /home/$USER/.profile /home/$USER/.old_a_profile
fi
if [ -f /home/$USER/.git_bash_prompt ]; then 
	mv /home/$USER/.git_bash_prompt /home/$USER/.old_a_git_bash_prompt
fi
if [ -f /home/$USER/.gitconfig ]; then 
	mv /home/$USER/.gitconfig /home/$USER/.old_a_gitconfig
fi
if ([ -d aliases ] && [ -f .bash_aliases ]); then
	echo "Making Sym Links from current install location"
	ln -s "$(pwd -P)"/.bash_aliases /home/$USER/
	ln -s "$(pwd -P)"/.bashrc /home/$USER/
	ln -s "$(pwd -P)"/.profile /home/$USER/
	ln -s "$(pwd -P)"/.git_bash_prompt /home/$USER/
	ln -s "$(pwd -P)"/dotfiles/.gitconfig /home/$USER/
	touch /home/$USER/.ran_profiles_once
else
  if ([ -d /opt/profiles/aliases ] && [ -f /opt/profiles/.bash_aliases ]); then
    echo "Making Sym Links from /opt/profiles install location"
	ln -s /opt/profiles/.bash_aliases /home/$USER/
	ln -s /opt/profiles/.bashrc /home/$USER/
	ln -s /opt/profiles/.profile /home/$USER/
	ln -s /opt/profiles/.git_bash_prompt /home/$USER/
	ln -s /opt/profiles/dotfiles/.gitconfig /home/$USER/
	touch /home/$USER/.ran_profiles_once
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
