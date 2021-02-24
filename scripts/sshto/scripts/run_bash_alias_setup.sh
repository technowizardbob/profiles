#!/bin/bash

if [ -f "$HOME/.ran_profiles_once" ]; then
        echo -e "Already run once for this user!!\n"
        exit 1
fi

sudo mkdir -p /opt/profiles 2> /dev/null
pushd /opt/profiles
sudo tar -xvzf ~/bash_aliases.tar.gz

bnow=$(date +"%m_%d_%Y_%H_%M_%S")
mkdir -p "$HOME/.dotfile_backups/$bnow" 2> /dev/null
cp "$HOME"/{.bash_aliases,.bashrc,.profile,.git_bash_prompt,.vimrc,.gitconfig,.gitconfig.secret} "$HOME/.dotfile_backups/$bnow/" 2> /dev/null

rm ~/.git_bash_prompt 2> /dev/null
mv ~/.bashrc ~/.bashrc_old  2> /dev/null
mv ~/.bash_aliases ~/.bash_aliases_old  2> /dev/null
ln -s /opt/profiles/.bashrc ~/.bashrc  2> /dev/null
ln -s /opt/profiles/.git_bash_prompt ~/.git_bash_prompt  2> /dev/null
ln -s /opt/profiles/.bash_aliases ~/.bash_aliases  2> /dev/null
popd

rm ~/bash_aliases.tar.gz
touch "$HOME/.ran_profiles_once"
