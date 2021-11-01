#!/bin/bash
if [ -r /opt/profiles/skip_php_check ]; then
	exit 0
fi
if [ -x /bin/apt-get ] || [ -x /usr/bin/apt-get ]; then
	retPHP=$(php -v | grep "PHP 8.0" | wc -l)
	if [ "$retPHP" != "1" ]; then
    		echo "PHP 8.0 CLI needs to be installed..."
    		sudo add-apt-repository ppa:ondrej/php
    		sudo apt install php8.0-cli
	fi
	retSQL=$(php -m | grep "sqlite3")
	if [ "$retSQL" != "sqlite3" ]; then
	    	echo "PHP 8.0 SQLite3 needs to be installed..."
    		sudo apt install php8.0-sqlite3
	fi
fi
