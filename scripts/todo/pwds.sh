#!/bin/bash
/opt/profiles/scripts/todo/setup_php8_cli.sh
retUSER=$(whoami)
php -c /opt/profiles/scripts/todo/php_todo.ini -f /opt/profiles/scripts/todo/pwds.php -- $@ -who "$retUSER"
