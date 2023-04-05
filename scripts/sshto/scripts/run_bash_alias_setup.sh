#!/bin/bash

if [ -z "$_PROFILES_PATH" ]; then
   _PROFILES_PATHS=/opt/profiles/
else
   _PROFILES_PATHS=${_PROFILES_PATH}
fi


sudo mkdir -p ${_PROFILES_PATHS} 2> /dev/null
pushd ${_PROFILES_PATHS}
sudo tar -xvzf ~/bash_aliases.tar.gz

if [ -f "$HOME/.ran_profiles_once" ]; then
        echo -e "Already run once for this user!!\n"
        popd
        exit 1
fi

bnow=$(date +"%m_%d_%Y_%H_%M_%S")
mkdir -p "$HOME/.dotfile_backups/$bnow" 2> /dev/null
cp "$HOME"/{.bash_aliases,.bashrc,.profile,.git_bash_prompt,.vimrc,.gitconfig,.gitconfig.secret} "$HOME/.dotfile_backups/$bnow/" 2> /dev/null

rm ~/.git_bash_prompt 2> /dev/null
mv ~/.bashrc ~/.bashrc_old  2> /dev/null
mv ~/.bash_aliases ~/.bash_aliases_old  2> /dev/null
ln -s ${_PROFILES_PATHS}.bashrc ~/.bashrc  2> /dev/null
ln -s ${_PROFILES_PATHS}.git_bash_prompt ~/.git_bash_prompt  2> /dev/null
ln -s ${_PROFILES_PATHS}.bash_aliases ~/.bash_aliases  2> /dev/null
popd

rm ~/bash_aliases.tar.gz
touch "$HOME/.ran_profiles_once"
