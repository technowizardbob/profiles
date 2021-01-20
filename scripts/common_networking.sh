#!/bin/sh
#Get Sub-Network
export SN=`netstat -nr | grep -m 1 -iE 'default|0.0.0.0' | awk '{print \$2}' | sed 's/\.[0-9]*$//' `
#Get Default Gateway
export GW=`netstat -nr | grep -m 1 -iE 'default|0.0.0.0' | awk '{print $2}'`
while :
do
	/bin/echo "(0) Find common servers"
	/bin/echo "(1) Find web servers"
	/bin/echo "(2) Find file servers"
	/bin/echo "(3) Find SSH servers"
	/bin/echo "(4) Find FTP servers"
	/bin/echo "(5) Quick Check Internet"
	/bin/echo "(6) Ping Internet until ctrl-c"
	/bin/echo "(q) Quit or Enter"
	read netcmd
	if [ -z "$netcmd" ] || [ $netcmd = q ]; then
  		exit 0
	elif [ $netcmd = 0 ]; then
		nmap --top-ports 10 "$SN".*
	elif [ $netcmd = 1 ]; then
		nmap -p 80,443,8080 "$SN".*
	elif [ $netcmd = 2 ]; then
		nmap -p 137,138,139,445 "$SN".*
	elif [ $netcmd = 3 ]; then
		nmap -p 22 "$SN".*
	elif [ $netcmd = 4 ]; then
		nmap -p 21 "$SN".*
	elif [ $netcmd = 5 ]; then
		/bin/ping -c 5 -i .250 -s 2 "$GW"
	elif [ $netcmd = 6 ]; then
		/bin/ping "$GW"
	fi
done
