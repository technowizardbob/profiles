#!/bin/bash
if [ "$EUID" -ne 0 ]; then
	echo "Run as Root"
	exit 1
fi
if [ -f /etc/skel/.ran_profiles_once ]; then
	echo "Already installed."
	exit 1
fi
touch /etc/skel/.ran_profiles_once
mv /etc/skel/.bashrc /etc/skel/.bashrc.old
mv /etc/skel/.profile /etc/skel/.profile.old
if [ -d aliases ] && [ -f .bash_aliases ]; then
	ln -s "$(pwd -P)"/.bash_aliases /etc/skel/
	ln -s "$(pwd -P)"/.bashrc /etc/skel/
	ln -s "$(pwd -P)"/.profile /etc/skel/
	ln -s "$(pwd -P)"/.git_bash_prompt /etc/skel/
	ln -s "$(pwd -P)"/.kube-ps1 /etc/skel/
    if [ ! -f /etc/skel/.nanorc ]; then
        cp "$(pwd -P)"/dotfiles/.nanorc /etc/skel/
    fi
    if [ ! -f /etc/skel/.tmux.conf ]; then
        cp "$(pwd -P)"/dotfiles/.tmux.conf /etc/skel/
    fi
    if [ ! -f /etc/skel/.vimrc ]; then
        cp "$(pwd -P)"/dotfiles/.vimrc /etc/skel/
    fi
	exit 0
fi
echo "Making Sym Links for new users..."
ln -s /opt/profiles/.bash_aliases /etc/skel/
ln -s /opt/profiles/.bashrc /etc/skel/
ln -s /opt/profiles/.profile /etc/skel/
ln -s /opt/profiles/.git_bash_prompt /etc/skel/
ln -s /opt/profiles/.kube-ps1 /etc/skel/
if [ ! -f /etc/skel/.nanorc ]; then
   cp /opt/profiles/dotfiles/.nanorc /etc/skel/
fi
if [ ! -f /etc/skel/.tmux.conf ]; then
   cp /opt/profiles/dotfiles/.tmux.conf /etc/skel/
fi
if [ ! -f /etc/skel/.vimrc ]; then
   cp /opt/profiles/dotfiles/.vimrc /etc/skel/
fi
