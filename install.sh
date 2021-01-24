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
    [ -f /home/$USER/.old_a_gitconfig ] || [ -f /home/$USER/.old_a_vimrc ] || \
    [ -f /home/$USER/.ran_profiles_once ]); then
    	echo -e "Already run once for this user!!"
	exit 1
fi
if [ -f /home/$USER/.bash_aliases ]; then
	echo -e "\n"
	mv -v /home/$USER/.bash_aliases /home/$USER/.old_a_bash_aliases
        echo "Moved existing Bash Aliases - Dot File!!! to ~/.old_a_bash_aliases"
        echo "If something does not work anymore in bash alias...edit the backup..."
fi
if [ -f /home/$USER/.bashrc ]; then
	echo -e "\n"
	mv -v /home/$USER/.bashrc /home/$USER/.old_a_bashrc
        echo "Moved existing Bash RC - Dot File!!! to ~/.old_a_bash_rc"
        echo "If something does not work anymore in bashrc edit the backup..."
fi
if [ -f /home/$USER/.profile ]; then
	echo -e "\n"
	mv -v /home/$USER/.profile /home/$USER/.old_a_profile
        echo "Moved existing Profile - Dot File!!! to ~/.old_a_profile"
        echo "If something does not work anymore in the profile edit the backup..."
fi
if [ -f /home/$USER/.git_bash_prompt ]; then
	echo -e "\n"
	mv -v /home/$USER/.git_bash_prompt /home/$USER/.old_a_git_bash_prompt
        echo "Moved existing Git Prompt - Dot File!!! to ~/.old_a_git_bash_prompt"
        echo "If something does not look right anymore in git prompt edit the backup..."
fi
if [ -f /home/$USER/.gitconfig ]; then
	echo -e "\n"
	mv -v /home/$USER/.gitconfig /home/$USER/.old_a_gitconfig
        echo "Moved existing Git Config - Dot File!!! to ~/.old_a_gitconfig"
        echo "If something does not work anymore in Git edit the backup..."
fi
if [ -f /home/$USER/.vimrc ]; then
	echo -e "\n"
	mv -v /home/$USER/.vimrc /home/$USER/.old_a_vimrc
        echo "Moved existing VIM Config - Dot File!!! to ~/.old_a_vimrc"
        echo "If something does not work anymore in Vim edit the backup..."
fi
if ([ -d aliases ] && [ -f .bash_aliases ]); then
	echo -e "\n"
	echo "Making Sym Links from current install location"
	ln -s "$(pwd -P)"/.bash_aliases /home/$USER/
	ln -s "$(pwd -P)"/.bashrc /home/$USER/
	ln -s "$(pwd -P)"/.profile /home/$USER/
	ln -s "$(pwd -P)"/.git_bash_prompt /home/$USER/
	ln -s "$(pwd -P)"/dotfiles/.gitconfig /home/$USER/
	ln -s "$(pwd -P)"/dotfiles/.vimrc /home/$USER/
	if [ ! -f /home/$USER/.gitconfig.secret ]; then
   		cp "$(pwd -P)"/dotfiles/.gitconfig.secret /home/$USER/
   		nano /home/$USER/.gitconfig.secret
	fi
	touch /home/$USER/.ran_profiles_once
else
  if ([ -d /opt/profiles/aliases ] && [ -f /opt/profiles/.bash_aliases ]); then
	echo -e "\n"
	echo "Making Sym Links from /opt/profiles install location"
	ln -s /opt/profiles/.bash_aliases /home/$USER/
	ln -s /opt/profiles/.bashrc /home/$USER/
	ln -s /opt/profiles/.profile /home/$USER/
	ln -s /opt/profiles/.git_bash_prompt /home/$USER/
	ln -s /opt/profiles/dotfiles/.gitconfig /home/$USER/
	ln -s /opt/profiles/dotfiles/.vimrc /home/$USER/
	if [ ! -f /home/$USER/.gitconfig.secret ]; then
   		cp /opt/profiles/dotfiles/.gitconfig.secret /home/$USER/
   		nano /home/$USER/.gitconfig.secret
	fi
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
