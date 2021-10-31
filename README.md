# profiles
Bash Aliases :rocket:

# INSTALL:
You will need sudoers/root access to do install -- To: /opt/profiles folder.

Notice: I reference /opt/profiles folders a lot...in code, as it's a nice unused place for it to live at...

Sorry, if you wanted /usr/local/bin or something else....

####As with any software...Please backup your system before installation begains....
If you use the installer I make best efforts to auto backup to ~/.dotfile_backups
So, please go to that folder if your {vimrc,bashrc,bash_aliases} is gone...as it will be...moved/copied.

Download from github to $HOME/profiles and extract there...via the following git clone command:
```bash
$ cd ~

$ git clone https://github.com/tryingtoscale/profiles.git

Then:$ sudo mv profiles/ /opt/

Next, goto this folder:$ cd /opt/profiles

Now, as a non-Root USER from a console:$ ./install.sh

Note: It will edit the git config file so it has your name and email at this point.

# To install package dependencies: 
   -   (review arch_deps.list or debian_deps.list depending on your system)
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
mv $HOME/.bash_aliases $HOME/.old_bash_aliases

mv $HOME/.bashrc $HOME/.old_bashrc

mv $HOME/.profile $HOME/.old_profile
.........and other dotfiles.........listed below.
```
## Make links to Bash Aliases:
```bash
ln -s /opt/profiles/.bash_aliases $HOME/

ln -s /opt/profiles/.bashrc $HOME/

ln -s /opt/profiles/.profile $HOME/

ln -s /opt/profiles/.git_bash_prompt $HOME/

(Optionaly, if you do not have an .gitconfig or .vimrc, yet):

cp /opt/profiles/dotfiles/.gitconfig $HOME/
....be sure to edit the .gitconfig.secret and save it to $HOME/

cp /opt/profiles/dotfiles/.vimrc $HOME/

exit && relog in... for changes to take effect
```

---

# Customize your Aliases:

 - [x] Add/Remove/Change any Bash Alias in: $ cd /opt/profiles/custom_aliases/

These will not get clobbered with every git pull request....

# Usage:

See list of all scripts, type: cmd

Example, to look at a script: cmd web

ex2: cmd git

ex3: cmd apt_get

ex4: cmd docker

To SSH into a box: sshto ( will setup .ssh folder/RSA keys/config for you )

To generate a password: pwdgen

List all git projects: gp ( GUI that will create list of projects.
  -- Also, git prompt for add/remove/comment/pull/pushing to project )

Auto CD into git project: gpcd

To edit an alias do: calias folders

To find something Quick: alias-find netstat

Grep search text in current folders or a path given: lookfor "hardtofindthing" 

To get help with a cheat-sheet: cheat

ex1: cheat chmod

ex2: cheat kubernetes

ex3: cheats

If, you forget about this README.md file, type: $ guide

.SH AUTHOR
Robert S. <Robert@TryingToScale.com>

:octocat: [On GitHub -> TryingToScale.com](https://github.com/tryingtoscale)

[My Site -> TryingToScale.com](https://TryingToScale.com)

[CoC](https://github.com/tryingtoscale/profiles/blob/main/CoC/CoC.md)
