#!/bin/bash

clear

if [ "$EUID" -eq 0 ]; then
    echo -e "\nPlease backup and make sym-links your self for the root account, as I do not want to make a admin mad.\n"
    echo "See README.md for manuall instructions for install of sym-links."
    echo "ln -s /pathHere/{.bashrc,.bash_aliases,.profile,.git_bash_prompt} /root/"
    echo -e "\nAlso, for dotfiles folder....\n"
    echo -e "\nAlso, if you want all new users to have the same aliases....link to /etc/skel/ \n"
    exit 1
fi

if [ -d $HOME ]; then
   HPATH=$HOME
elif [ -d /home/$USER ]; then
   HPATH=$HPATH
else
   echo "Unable to Find user HOME folder!!!!"
   exit 1
fi

if [ -z "$1" ]; then
  if [ ! -d /opt/profiles ]; then
     echo -e "Please use the default install path of /opt/profiles\n - as it is hard coded everywhere...."
     echo "You may override this by using \$ install.sh --force"
     echo "Beware, if using force option it does not update any working paths! Be in the folder you want to use IE: \$ cd /usr/local/bin/profiles"
     echo "It you really want it installed to somewhere else I would make a symbolic link to /opt/profiles"
     exit 1
  fi
  pushd /opt/profiles > /dev/null
elif [ $1 == "--force" ]; then
     echo "Don't forget to make a sym-link to /opt/profiles"
fi

if [ -z "$1" ] || [ ! "$1" == "---dangerious-reload" ]; then
  if ([ -f $HPATH/.old_a_bash_aliases ] || [ -f $HPATH/.old_a_bashrc ] || \
    [ -f $HPATH/.old_a_profile ] || [ -f $HPATH/.old_a_git_svn_bash_prompt ] || \
    [ -f $HPATH/.old_a_gitconfig ] || [ -f $HPATH/.old_a_vimrc ] || \
    [ -f $HPATH/.ran_profiles_once ]); then
        echo -e "Already run once for this user!!\n"
        echo -e "Success, I think!?\n \t --- If NOT and you have broken symbolic Links, well then:::"
        echo "If, not sure then see manual install guide from README.md!!"
        echo "Its best to just do it manually at this point."
        echo "To override and reload, which BTW would blow away the auto moved backups...."
        echo "So, in that case, Please MAKE your own BACKUPs of all your DOT-FILES!!!!!"
        echo "If its broken and you understand the RISKS use: ---dangerious-reload"
        if [ -d $HPATH/.dotfile_backups ]; then
           echo "FYI - I made extra backups in ~/.dotfile_backups"
           ls -la $HPATH/.dotfile_backups
        fi   
    exit 1
  fi
fi

bnow=$(date +"%m_%d_%Y_%H_%M_%S")
mkdir -p $HPATH/.dotfile_backups/$bnow 2> /dev/null
cp $HPATH/{.bash_aliases,.bashrc,.profile,.git_bash_prompt,.vimrc,.gitconfig,.gitconfig.secret} $HPATH/.dotfile_backups/$bnow/ 2> /dev/null
cp /etc/hosts $HPATH/.dotfile_backups/$bnow/ 2> /dev/null

if [ -f $HPATH/.bash_aliases ]; then
    echo -e "\n"
    mv -v $HPATH/.bash_aliases $HPATH/.old_a_bash_aliases
        echo "Moved existing Bash Aliases - Dot File!!! to ~/.old_a_bash_aliases"
        echo "If something does not work anymore in bash alias...edit the backup..."
fi
if [ -f $HPATH/.bashrc ]; then
    echo -e "\n"
    mv -v $HPATH/.bashrc $HPATH/.old_a_bashrc
        echo "Moved existing Bash RC - Dot File!!! to ~/.old_a_bash_rc"
        echo "If something does not work anymore in bashrc edit the backup..."
fi
if [ -f $HPATH/.profile ]; then
    echo -e "\n"
    mv -v $HPATH/.profile $HPATH/.old_a_profile
        echo "Moved existing Profile - Dot File!!! to ~/.old_a_profile"
        echo "If something does not work anymore in the profile edit the backup..."
fi
if [ -f $HPATH/.git_bash_prompt ]; then
    echo -e "\n"
    mv -v $HPATH/.git_bash_prompt $HPATH/.old_a_git_bash_prompt
        echo "Moved existing Git Prompt - Dot File!!! to ~/.old_a_git_bash_prompt"
        echo "If something does not look right anymore in git prompt edit the backup..."
fi
###### My .gitconfig && .vimrc are not all that great, so....let's not wipe yours!
#if [ -f $HPATH/.gitconfig ]; then
#    echo -e "\n"
#    mv -v $HPATH/.gitconfig $HPATH/.old_a_gitconfig
#        echo "Moved existing Git Config - Dot File!!! to ~/.old_a_gitconfig"
#        echo "If something does not work anymore in Git edit the backup..."
#fi
#if [ -f $HPATH/.vimrc ]; then
#    echo -e "\n"
#    mv -v $HPATH/.vimrc $HPATH/.old_a_vimrc
#        echo "Moved existing VIM Config - Dot File!!! to ~/.old_a_vimrc"
#        echo "If something does not work anymore in Vim edit the backup..."
#fi

if ([ -d aliases ] && [ -f .bash_aliases ]); then
    echo -e "\n"
    echo "Making Sym Links from current install location"
    ln -s "$(pwd -P)"/.bash_aliases $HPATH/
    ln -s "$(pwd -P)"/.bashrc $HPATH/
    ln -s "$(pwd -P)"/.profile $HPATH/
    ln -s "$(pwd -P)"/.git_bash_prompt $HPATH/
    if [ ! -f $HPATH/.gitconfig ]; then
      cp "$(pwd -P)"/dotfiles/.gitconfig $HPATH/
    fi
    if [ ! -f $HPATH/.vimrc ]; then  
       cp "$(pwd -P)"/dotfiles/.vimrc $HPATH/
    fi
    if [ ! -f $HPATH/.gitconfig.secret ]; then
        cp "$(pwd -P)"/dotfiles/.gitconfig.secret $HPATH/
        nano $HPATH/.gitconfig.secret
    fi
    touch $HPATH/.ran_profiles_once
else
  if ([ -d /opt/profiles/aliases ] && [ -f /opt/profiles/.bash_aliases ]); then
    echo -e "\n"
    echo "Making Sym Links from /opt/profiles install location"
    ln -s /opt/profiles/.bash_aliases $HPATH/
    ln -s /opt/profiles/.bashrc $HPATH/
    ln -s /opt/profiles/.profile $HPATH/
    ln -s /opt/profiles/.git_bash_prompt $HPATH/
    if [ ! -f $HPATH/.gitconfig ]; then
      cp /opt/profiles/dotfiles/.gitconfig $HPATH/
    fi
    if [ ! -f $HPATH/.vimrc ]; then  
       cp /opt/profiles/dotfiles/.vimrc $HPATH/
    fi
    if [ ! -f $HPATH/.gitconfig.secret ]; then
        cp /opt/profiles/dotfiles/.gitconfig.secret $HPATH/
        nano $HPATH/.gitconfig.secret
    fi
    touch $HPATH/.ran_profiles_once
  fi
fi

echo "See a list of commands Type: command"
echo "Example: command web"
echo "Ex2: command git"
echo "Ex3: command apt_get"
echo "Ex4: command docker"
echo "Ex5: command folders"
echo "For a GUIDE: \$ guide"
echo "Installed to local user account ${USER}. IE folder: ${HPATH}/"
echo -e "\nIf you had any dotfiles, they will be moved to ${HPATH}/.old_a_XXXX"
echo -e "Also, backed up to ~/.dotfile_backups/$bnow/ \n \t --- because I don't want you to loose any work....!"

if [ ! -e .ran_setup ]; then
   echo -e "\nYou should review first the setup.sh file then run it."
   echo -e "\$ setup.sh \n \t - which will install required packages...."
fi

if [ -z "$1" ]; then
   popd > /dev/null
fi
