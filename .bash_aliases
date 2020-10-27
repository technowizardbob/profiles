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

if [ -f /opt/profiles/awesome.txt ]; then
	cat /opt/profiles/awesome.txt
fi

if [ -f /opt/profiles/mysite.txt ]; then
	cat /opt/profiles/mysite.txt
fi

date +"%A, %B %-d, %Y %r"

#Check if Root
if [ $UID -ne 0 ]; then
    # This is not a root user:	
    echo "Welcome, " `whoami`
    echo "This is a protected system! All access is logged." 
    alias reboot='sudo reboot'
    alias upgrade='sudo apt-get upgrade'
else 
    # Wow, got root:		
    echo "You are logged in as an admin becareful! This is a restricted system, this will be logged."
    alias upgrade='apt-get upgrade'
fi
