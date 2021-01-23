# profiles
Bash Aliases

.TH "Bash Aliases" "1" "January 2021" "Profiles-1.X" "User manual"
.SH NAME
Profiles-1X \- BASH scripts to manage your aliases.
.SH DESCRIPTION
.nf

# INSTALL:
Download from github to /home/$USER/profiles and extract there...via the following git clone command:
```bash
$ cd ~

$ git clone https://github.com/tryingtoscale/profiles.git

Then:$ sudo mv profiles/ /opt/

Next:$ goto this folder: cd /opt/profiles

$ chmod 774 install.sh
Now, as a non-Root USER from a console:$ ./install.sh

# Ubuntu Font for Cool Term, do not do on Windows linux-subsystem:
$ sudo apt-get install fonts-powerline

$ touch /opt/profiles/.unicode_support

# Customize your banner: 
$ mv /opt/profiles/bw_awesome.txt /opt/profiles/awesome.txt

# (Optional) To disable Background colors:
touch /opt/profiles/.simple_theme
```
---

# If NOT using the install.sh installer follow these steps:

# First Backup any changes to these files, then remove them:
```bash
mv /home/$USER/.bash_aliases /home/$USER/.old_bash_aliases

mv /home/$USER/.bashrc /home/$USER/.old_bashrc

mv /home/$USER/.profile /home/$USER/.old_profile
```
# Make links to Bash Aliases:
```bash
ln -s /opt/profiles/.bash_aliases /home/$USER/

ln -s /opt/profiles/.bashrc /home/$USER/

ln -s /opt/profiles/.profile /home/$USER/

ln -s /opt/profiles/.git_bash_prompt /home/$USER/

exit && relog in... for changes to take effect
```
# Usage:

for list of all commands/aliases type: commands

see list of scripts type: command

After command : type filename without the .env extension.

example: command web

ex2: command git

ex3: command apt_get

ex4: command docker

To SSH into a box: sshto

To generate a password: pwdgen

To edit an alias do: calias folders

To find something Quick: alias-find netstat

To get help with a cheat-sheet: cheat

ex1: cheat chmod

ex2: cheat kubernetes

ex3: cheats

.SH AUTHOR
Robert S. <Robert@TryingToScale.com>
.SH GITHUB
https://github.com/tryingtoscale
