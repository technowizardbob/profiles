# to change default editor change order here:
if [ -x /bin/nano ] || [ -x /usr/bin/nano ]; then
  export EDITOR=nano
elif [ -x /bin/neovim ] || [ -x /usr/bin/neovim ]; then
  export EDITOR=neovim
elif [ -x /bin/vim ] || [ -x /usr/bin/vim ]; then
  export EDITOR=vim
elif [ -x /bin/vi ] || [ -x /usr/bin/vi ]; then
  export EDITOR=vi
elif [ -x /bin/emacs ] || [ -x /usr/bin/emacs ]; then
  export EDITOR=emacs
elif [ -x /bin/pico ] || [ -x /usr/bin/pico ]; then
  export EDITOR=pico
else
  export EDITOR=nano
fi

if [ -x /bin/geany ] || [ -x /usr/bin/geany ]; then
  export VISUAL=geany
elif [ -x /bin/sublime ] || [ -x /usr/bin/sublime ]; then
  export VISUAL=sublime
elif [ -x /bin/gvim ] || [ -x /usr/bin/gvim ]; then
  export VISUAL=gvim
elif [ -x /bin/kate ] || [ -x /usr/bin/kate ]; then
  export VISUAL=kate
elif [ -x /bin/gedit ] || [ -x /usr/bin/gedit ]; then
  export VISUAL=gedit
elif [ -x /bin/leafpad ] || [ -x /usr/bin/leafpad ]; then
  export VISUAL=leafpad
elif [ -x /bin/medit ] || [ -x /usr/bin/medit ]; then
  export VISUAL=medit
elif [ -x /bin/atom ] || [ -x /usr/bin/atom ]; then
  export VISUAL=atom
elif [ -x /bin/emacs ] || [ -x /usr/bin/emacs ]; then
  export VISUAL=emacs
else
  export VISUAL=geany
fi

_PROFILES_PATH="/opt/profiles/"
_ENV_PATH="${_PROFILES_PATH}aliases/"
_ENV_FILES="${_ENV_PATH}*.env"
# List these alias Commands, this file...
commands() {
	echo "..." > /tmp/commands.txt
	for f in $_ENV_FILES;
	do
		echo "Reading Aliases for ${f}" >> /tmp/commands.txt
		cat "${f}" >> /tmp/commands.txt
	done
	less /tmp/commands.txt
}
command() {
	if [ -f "${_ENV_PATH}$1.env" ];	then
                less "${_ENV_PATH}$1.env"
	else 
		for c in $_ENV_FILES; 
		do 
			echo $c
		done
	fi
}
for f in $_ENV_FILES;
do
	source "${f}"
done
