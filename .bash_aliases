_ENV_PATH="/opt/profiles/aliases/"
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
	if [ -f "${_ENV_PATH}$1.env" ];	
	then
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
