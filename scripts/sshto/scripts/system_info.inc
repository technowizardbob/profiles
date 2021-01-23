system_info () {
    clear
    ssh $SSH_OPT $target "
        printf '\n${BLD}Hostname:${DEF}\n'
        hostname

        printf '\n${BLD}Interfaces:${DEF}\n'
        ip a

        printf '\n${BLD}Memory:${DEF}\n'
        LANG=Us free --si -h

        printf '\n${BLD}CPU:${DEF}\n'
        lscpu

        printf '\n${BLD}Disk:${DEF}\n'
        df -h; echo; df -ih; echo; lsblk

        printf '\n${BLD}Software:${DEF}\n'
        uname -a; echo
        [[ -e /usr/bin/lsb_release ]] && { lsb_release -a; echo; }
        [[ -e /usr/bin/java        ]] && { java  -version; echo; }
        [[ -e /usr/bin/psql        ]] && { psql  -V      ; echo; }
        [[ -e /usr/sbin/nginx      ]] && { nginx -v      ; echo; }
	    [[ -e /usr/sbin/apache2    ]] && { apache2 -v    ; echo; }
	    [[ -e /usr/bin/php         ]] && { php -v        ; echo; }
	    [[ -e /usr/bin/mysql       ]] && { mysql -v      ; echo; }

        printf '${BLD}Logged in Users:${DEF}\n'
        who

        printf '\n${BLD}Port usage info:${DEF}\n'
        netstat -tulpn 2> /dev/null

        printf '\n${BLD}Processes:${DEF}\n'
        top -bcn1 | head -n30
    "
    pause
}
