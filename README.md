# profiles
Bash Aliases :rocket:

# INSTALL:
Notice: I reference /opt/profiles folders a lot...in code, as it's a nice unused place for it to live at...
Sorry, if you wanted /usr/local/bin or something else....

####As with any software...Please backup your system before installation begains....
If you use the installer I make best efforts to auto backup to ~/.dotfile_backups
So, please go to that folder if your {vimrc,bashrc,bash_aliases} is gone...as it will be...moved/copied.

Download from github to /home/$USER/profiles and extract there...via the following git clone command:
```bash
$ cd ~

$ git clone https://github.com/tryingtoscale/profiles.git

Then:$ sudo mv profiles/ /opt/

Next, goto this folder:$ cd /opt/profiles

Now, as a non-Root USER from a console:$ ./install.sh

Note: It will edit the git config file so it has your name and email at this point.

# To install package dependencies: 
   -   (review arch_deps.list or debian_deps.list 
   -   depending on your system)
   -   as this will apt-get or pacman install system packages, 
   -   so ensure you got system backups....
$ ./setup_deps.sh

# (Optional) If on windows sub-system for Linux and your Fonts look bad...then
$ rm /opt/profiles/.unicode_support

# Customize your banner: 
$ mv /opt/profiles/bw_awesome.txt /opt/profiles/awesome.txt

# (Optional) To disable Background colors, if annoying:
touch /opt/profiles/.simple_theme

# (Optional) Install FireJailed FireFox Icons for Gnome Desktop:
$ ./firejail_firefox_icons.sh

# Your done, so exit or reload $ alias-reload

```
---

# If NOT using the install.sh installer follow these steps:

## First Backup any changes to these files, move them:
```bash
mv /home/$USER/.bash_aliases /home/$USER/.old_bash_aliases

mv /home/$USER/.bashrc /home/$USER/.old_bashrc

mv /home/$USER/.profile /home/$USER/.old_profile
.........and other dotfiles.........listed below.
```
## Make links to Bash Aliases:
```bash
ln -s /opt/profiles/.bash_aliases /home/$USER/

ln -s /opt/profiles/.bashrc /home/$USER/

ln -s /opt/profiles/.profile /home/$USER/

ln -s /opt/profiles/.git_bash_prompt /home/$USER/

ln -s /opt/profiles/dotfiles/.gitconfig /home/$USER/
....be sure to edit the .gitconfig.secret and save it to /home/$USER/

ln -s /opt/profiles/dotfiles/.vimrc /home/$USER/

exit && relog in... for changes to take effect
```

---

# Customize your Aliases:

Add/Remove/Change any Bash Alias in: $ cd /opt/profiles/custom_aliases/

These will not get clobbered with every git pull request....

# Usage:

for list of all commands/aliases type: commands

see list of scripts type: command

After command : type filename without the .env extension.

example: command web

ex2: command git

ex3: command apt_get

ex4: command docker

To edit SSH config: essh

To SSH into a box: sshto ( will setup .ssh folder/RSA keys/config for you )

To generate a password: pwdgen

To work on a git Project repo: dogit /var/www/reponame

List all git projects: gp ( GUI that will create list of projects )

Auto CD into git project: gcd

To edit an alias do: calias folders

To find something Quick: alias-find netstat

To get help with a cheat-sheet: cheat

ex1: cheat chmod

ex2: cheat kubernetes

ex3: cheats

.SH AUTHOR
Robert S. <Robert@TryingToScale.com>

:octocat: [On GitHub -> TryingToScale.com](https://github.com/tryingtoscale)

[My Site -> TryingToScale.com](https://TryingToScale.com)
