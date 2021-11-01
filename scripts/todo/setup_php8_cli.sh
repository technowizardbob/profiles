#!/bin/bash
if [ ! -d /usr/local/share/man/man1 ]; then
    sudo mkdir -p /usr/local/share/man/man1
fi
if [ -r /opt/profiles/scripts/todo/todo.1 ]; then
    if [ ! -r /usr/local/share/man/man1/todo.1.gz ]; then
        sudo install -g 0 -o 0 -m 0644 /opt/profiles/scripts/todo/todo.1 /usr/local/share/man/man1/
        sudo gzip /usr/local/share/man/man1/todo.1
    fi
fi
if [ -r /opt/profiles/scripts/todo/pwds.1 ]; then
    if [ ! -r /usr/local/share/man/man1/pwds.1.gz ]; then
        sudo install -g 0 -o 0 -m 0644 /opt/profiles/scripts/todo/pwds.1 /usr/local/share/man/man1/
        sudo gzip /usr/local/share/man/man1/pwds.1
    fi
fi
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
