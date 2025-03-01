#!/bin/bash
PW_FOLDER="$HOME/.mypwds"
ME=$(whoami)
export PASSWORD_STORE_CLIP_TIME=75
export PASSWORD_STORE_DIR="$PW_FOLDER/stores" 
export GNUPGHOME="$PW_FOLDER"

editors=("gnome-text-editor" "mousepad" "leafpad" "kwrite" "kate" "pluma" "xed" "geany" "brackets" "notepadqq" "code" "nano" "vi")
for editor in "${editors[@]}"; do
	full_path=$(command -v "$editor" 2> /dev/null)
    if [ -n "$full_path" ]; then
        export EDITOR="$full_path"
        break
    fi
done

# Function to check if a program is installed
check_program() {
    local program=$1
    if ! command -v "$program" &> /dev/null; then
        if [ "$program" == "gpg2" ]; then
            echo "$program is not installed. You can install it with:"
            echo "  sudo apt update && sudo apt install gnupg2"
        else
            echo "$program is not installed. You can install it with:"
            echo "  sudo apt update && sudo apt install $program"
        fi
        exit 1
    fi
}
# Programs to check
programs=("pass" "gpg2" "xclip")
for program in "${programs[@]}"; do
    check_program "$program"
done

a-long-password() {
  if [ -z "$1" ]; then
    local random_string=$(openssl rand -base64 24)
  else
    local random_string=$(openssl rand -base64 "$1")
  fi
  local possible_symbols='@#,%.&*()^?'
  local num_symbols=$((RANDOM % ${#possible_symbols} + 1))
  extra_symbols=$(echo "$possible_symbols" | fold -w1 | shuf | head -n "$num_symbols" | tr -d '\n')
  local combined_string="${random_string}${extra_symbols}"
  LCAP=$(echo "$combined_string" | fold -w1 | shuf | tr -d '\n')
}
a-good-pass() {
  local password=$LCAP
  # Get the length of the password
  local password_length=${#password}
  # Calculate half the length of the password
  local half_length=$((password_length / 2))
  # Generate a random starting position between 0 and half_length
  local start_position=$((RANDOM % (password_length - half_length + 1)))
  # Calculate a random length for the substring between half_length and      password_length
  local substring_length=$((RANDOM % (password_length - half_length + 1) + half_length))
  # Extract the substring
  local substring=${password:start_position:substring_length}
  GCAP=$(echo "$substring" | fold -w1 | shuf | tr -d '\n')
}
a-normal-pass() {
    export LC_ALL=C
	local PWD_SIZE=$((9 + RANDOM % 16)) # Min 9, Max 9 + 16
	local PCS='@#%^&*()_-+=[].,;:?'
	local SPC=${PCS:$((RANDOM % ${#PCS})):1}   # Start Random special char.
	local EPC=${PCS:$((RANDOM % ${#PCS})):1}   # End Random special char.
	local tpwd=$(grep -ao '[A-Za-z0-9]' /dev/urandom \
		| head -n $PWD_SIZE \
		| shuf \
		| tr -d 'ioIOlL01\n')
	# Check if the variable contains a digit
	if [[ ! $tpwd =~ [0-9] ]]; then
		# Generate a random number from 2 to 99
		random_number=$((RANDOM % 98 + 2))
		# Append the random number to the variable
		local tpwd="${tpwd}${random_number}"
	fi
	NCAP=$(echo "${SPC}${tpwd}${EPC}" | fold -w1 | shuf | tr -d '\n')
}

pick_option() {
  a-long-password
  a-good-pass
  a-normal-pass	
  echo "Please pick an option:"
  echo "1. Use LONG   Password: $LCAP"
  echo "2. Use Good   Password: $GCAP"
  echo "3. Use Normal Password: $NCAP"
  echo "4. Fetch Password."
  echo "5. Edit/Add Password."
  read -n 1 -r -p "Enter your choice (1, 2, 3, 4, or 5): " choice
  echo ""
  case "$choice" in
    1)
      CAP=$LCAP
      use_pwd
      ;;
    2)
      CAP=$GCAP
      use_pwd
      ;;
    3)
      CAP=$NCAP
      use_pwd
      ;;
    4)
      fetch_pwd
      ;;
    5)
      edit_pwd
      ;;
    *)
      echo "Invalid choice, please try again."
      pick_option # Call the function again for a valid input
      ;;
  esac
}

use_pwd() {
	if command -v xclip > /dev/null 2>&1; then
	   printf "%s" "${CAP//$'\n'/}" | xclip -selection clipboard
	   echo -e "This Password has been saved to the clip-board. Use CTRL+V to paste."
	else 
	   echo -e "please run \$ sudo apt install xclip \n"
	fi
	echo ""
	enter_pwd
}

do_init() {
  # Create the directory if necessary and initialize it
  mkdir -p "$PW_FOLDER/stores"
  chmod 700 "$PW_FOLDER"
  
  gpg2 --homedir "$PW_FOLDER" --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Expire-Date: 0
Name-Real: $ME
Name-Email: $ME@localhost.me
%commit
EOF
  gpg2 --homedir "$PW_FOLDER" --list-keys --with-colons | grep '^pub' | awk -F: '{print $5}' > "$PASSWORD_STORE_DIR/.gpg-id"
  pass init $(cat "$PASSWORD_STORE_DIR/.gpg-id")
}

init_pwds() {
	if [ ! -d "$PW_FOLDER" ]; then
		echo -e "Folder $PW_FOLDER does not exist.\nYou will be prompted to make a main password...\n"
		read -n 1 -r -p "Would you like to Initialize the password store, now (y/n)?" doit
		  case "$doit" in
			[yY])
			  do_init
			  ;;
		  esac
	fi	    
}
fetch_pwd() {
    export LC_ALL=en_US.UTF-8
    pass ls
    read -p "Enter the password file to view, EX: $ME/Chase Bank :" file
    pass "$file"
    pass "$file" -c
}
edit_pwd() {
    export LC_ALL=en_US.UTF-8
    pass ls
    read -p "Enter the password file to edit, EX: $ME/Chase Bank :" file
    pass edit "$file"
	check=$(pass "$file")
	# Remove Empty Passwords
	if [[ -z "$check" ]]; then
		pass rm "$file"
    fi
}
clearclip=false
enter_pwd() {
	read -n 1 -r -p "Would you like to Save this Password (y/n)?" doit
	  case "$doit" in
		[yY])
			echo -e "\n"
			read -p "Enter description, EX: Username :" desc
			read -p "Enter Entry System Name, EX: $ME/Chase Bank :" entry
			echo -e "$CAP\n$desc" | pass insert -m "$entry"
			clearclip=true
		  ;;
		[nN])
			echo -e "\nPlease, in some way, capture the password...\n"
		  ;;
		*)
		 	echo -e "\nInvalid choice...please try again.\n"
			enter_pwd
		  ;;
	  esac
}

init_pwds
pick_option
echo ""
if [ "$clearclip" = true ]; then
    read -n 1 -r -p "Press E key to empty clipboard and Exit, or use Enter key to just EXIT : " doit
	  case "$doit" in
		[eE])
   			echo -n "" | xclip -selection clipboard
			echo -e "\nClearing password, 1 second to exit...\n"
			sleep 1
		;;
	  esac
else
    read -n 1 -s -r -p "Press the Enter key to EXIT..."
fi
