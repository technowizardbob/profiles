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
	exit 0
fi
echo "Making Sym Links for new users..."
ln -s /opt/profiles/.bash_aliases /etc/skel/
ln -s /opt/profiles/.bashrc /etc/skel/
ln -s /opt/profiles/.profile /etc/skel/
ln -s /opt/profiles/.git_bash_prompt /etc/skel/
ln -s /opt/profiles/.kube-ps1 /etc/skel/
