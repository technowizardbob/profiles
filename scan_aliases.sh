#!/bin/bash

SANE_CHECKER="${_PROFILES_PATH}.sane_checker.sum"
SANE_CERTS="${_PROFILES_PATH}.sane_certs.sum"
export SHA_SUM_APP=/usr/bin/sha256sum
error_status=$(mktemp)

_f_do_as() {
    local file_name="$1"
    shift # Remove the first argment (the file)
    if [ -r "$file_name" ]; then
       $@
    else
       $USE_SUPER $@
    fi
}

if groups "$USER" | grep -o "sudo" >/dev/null 2>/dev/null; then
   USE_SUPER="sudo"
elif groups "$USER" | grep -o "doas" >/dev/null 2>/dev/null; then
   USE_SUPER="doas"
elif groups "$USER" | grep -o "wheel" >/dev/null 2>/dev/null; then
   USE_SUPER="sudo"
elif groups "$USER" | grep -o "admin" >/dev/null 2>/dev/null; then
   USE_SUPER="sudo"
elif [ "$EUID" -eq 0 ]; then
   USE_SUPER="\$"
else
   USE_SUPER=""
fi
export USE_SUPER
SANE_TEST_FAILED=0

tmpsum=$(mktemp -u --suffix ".sum.tmp")
tmpsum2=$(mktemp -u --suffix ".sum2.tmp")

# Spinner function with multiple animation styles
spinner() {
    local pid=$1
    local style=${2:-0}
    local delay=0.1
    
    case $style in
        0) local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' ;; # Braille dots
        1) local chars='▁▂▃▄▅▆▇█▇▆▅▄▃▂▁' ;; # Growing bar
        2) local chars='_-~+=*@#.?' ;; # Arrows
        3) local chars='◐◓◑◒' ;; # Circle
        4) local chars='⣾⣽⣻⢿⡿⣟⣯⣷' ;; # Detailed Braille
    esac

    local color='\e[34m' # Blue color
    local reset='\e[0m'

    # Hide cursor
    tput civis

    while kill -0 $pid 2>/dev/null; do
        # Save cursor position
        echo -en "\e7"
        
        for ((i=0; i<${#chars}; i++)); do
            # Restore cursor position
            echo -en "\e8"
            echo -en "\e[H${color}[${chars:$i:1}] Scanning Files...${reset}"
            sleep $delay
        done
    done

    # Show cursor
    tput cnorm
    # Clear line
    echo -en "\r\033[K"
}


#shaXsum
require_root() {
  local sane_file_name="$1"
  local temp_file="$2"	
  if [ "$EUID" -eq 0 ]; then
    mv "$temp_file" "$sane_file_name"
    chown root:root "$sane_file_name"
    chmod 444 "$sane_file_name"
    chattr +i "$sane_file_name"
  else
    echo "Trying to make sane sum file Immutable for security purposes, Please enter ROOT password when prompted."
    if [ -n "$USE_SUPER" ] && sudo --validate; then
       sudo mv "$temp_file" "$sane_file_name"
       sudo chown root:root "$sane_file_name"
       sudo chmod 444 "$sane_file_name"
       sudo chattr +i "$sane_file_name"
    else
       echo "Please have a ROOT user make this file: $sane_file_name Immutable!"
    fi
  fi
}
prompter_for_fix() {
   echo "Verify the integerity of your aliases scripts, then run:"
   if [ ! -w "$SANE_CHECKER" ]; then
      echo -e "\r\n sudo chattr -i \"$SANE_CHECKER\" \r\n sudo chmod 664 \"$SANE_CHECKER\" \r\n sudo rm $SANE_CHECKER"
   else
      echo -e "sudo rm $SANE_CHECKER"
   fi
}
good=1
if [ ! -f "$SANE_CHECKER" ]; then
	   echo -e "\033[0;34m 1st run added to sane sum file! \033[0m"
	   $SHA_SUM_APP {/opt/profiles/*.sh,/opt/profiles/scripts/*.sh,/opt/profiles/aliases/*.env,/opt/profiles/custom_aliases/*.env,~/.bash_aliases,~/.bashrc,~/.bash_logout,~/.git_bash_prompt,~/.profile,~/.kube-ps1,/opt/profiles/theme} > "$tmpsum" 2>/dev/null
	   require_root "$SANE_CHECKER" "$tmpsum"
	   good=0
	else
	   if [ -w "$SANE_CHECKER" ]; then
		  echo -e "\033[0;31m Warning -- sane sum Security file is Mutable! Please have a Root User run: \r\n \033[0m sudo chmod 444 \"$SANE_CHECKER\" \r\n AND then run \r\n sudo chattr +i \"$SANE_CHECKER\" \r\n"
		  good=0
	   fi
fi	
if [ ! -f "$SANE_CERTS" ]; then
   echo -e "\033[0;34m 1st run added to sane certs sum file! \033[0m"
   $SHA_SUM_APP /etc/ssl/certs/* > "$tmpsum2" 2>/dev/null
   require_root "$SANE_CERTS" "$tmpsum2"
   good=0
else
   if [ -w "$SANE_CERTS" ]; then
	  echo -e "\033[0;31m Warning -- sane sum Cert Security file is Mutable! Please have a Root User run: \r\n \033[0m sudo chmod 444 \"$SANE_CERTS\" \r\n AND then run \r\n sudo chattr +i \"$SANE_CERTS\" \r\n"
	  good=0
   fi
fi
check_certificates() {
	if [ -f "$SANE_CHECKER" ]; then
	   for FILE in /opt/profiles/*.sh; do
		   if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
			  SANE_TEST_FAILED=1
		   fi
	   done
	   for FILE in /opt/profiles/scripts/*.sh; do
		   if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
			  echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses. \033[0m" >> "$error_status"
			  SANE_TEST_FAILED=1
		   fi
	   done
	   for FILE in /opt/profiles/aliases/*.env; do
		   if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
			  echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses. \033[0m" >> "$error_status"
			  SANE_TEST_FAILED=1
		   fi
	   done
	   for FILE in /opt/profiles/custom_aliases/*.env; do
		   if [ -f "$FILE" ] && ! grep -q "$FILE" "$SANE_CHECKER"; then
			  echo -e "\033[0;31m $FILE is a new file! \r\n Please Scan it for viruses. \033[0m" >> "$error_status"
			  SANE_TEST_FAILED=1
		   fi
	   done
	   if ! $SHA_SUM_APP --quiet -c "$SANE_CHECKER"; then
		  echo -e "\033[0;31m Danger...? Failed Sane checker!! \033[0m" >> "$error_status"
		  SANE_TEST_FAILED=1
	   fi
	fi

	if [ "$SANE_TEST_FAILED" -eq 1 ]; then
	   return 2
	fi

	if [ -f "$SANE_CERTS" ]; then
		changed=0
		for cert in /etc/ssl/certs/*; do
			if [ -f "$cert" ]; then  # Only process regular files
				if ! grep -q "$($SHA_SUM_APP "$cert")" "$SANE_CERTS"; then
					echo -e "\033[0;31mWARNING: Modified or new cert found: $cert \r\n \033[0m" >> "$error_status"
					changed=1
				fi
			fi	
		done
		if [ "$changed" -eq 1 ]; then
		   echo "Please -- Verify the integerity of your SSL Certs, then run:" >> "$error_status"
		   if [ ! -w "$SANE_CERTS" ]; then
			  echo -e "\r\n sudo chattr -i \"$SANE_CERTS\" \r\n sudo chmod 664 \"$SANE_CERTS\" \r\n sudo rm $SANE_CERTS" >> "$error_status"
		   else
			  echo -e "sudo rm $SANE_CERTS" >> "$error_status"
		   fi
		   SANE_TEST_FAILED=1
		fi
	fi
	if [ "$SANE_TEST_FAILED" -eq 1 ]; then
		return 1
	else
		return 0
	fi
}
# Create a temporary file to store the exit status
temp_status=$(mktemp)

if [ "$good" -eq 1 ]; then
	# Run the check in background and capture its exit status
	(check_certificates; echo $? > "$temp_status") &
	# Start spinner with style 0 (can be changed to 1-4 for different animations)
	spinner $! 0
	# Wait for background process to complete
	wait
	# Read the exit status and clean up
	exit_status=$(cat "$temp_status")
	if [ "$exit_status" -eq 2 ]; then
		prompter_for_fix
		SANE_TEST_FAILED=1
	else	
		SANE_TEST_FAILED=$exit_status
	fi    
fi
# sed to remove any evil ANSI codes
cat "$error_status" | sed -r 's/\x1b\[[0-9;]*m//g'
rm "$error_status"
rm "$temp_status"
source ${_PROFILES_PATH}scan_libs.sh
