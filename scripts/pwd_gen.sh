#!/bin/bash
export LC_ALL=C
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
  read -p "Enter your choice (1, 2, or 3): " choice

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
    *)
      echo "Invalid choice, please try again."
      pick_option # Call the function again for a valid input
      ;;
  esac
}

function use_pwd() {
	if command -v xclip > /dev/null 2>&1; then
	   printf "%s" "${CAP//$'\n'/}" | xclip -selection clipboard
	   echo -e "This Password has been saved to the clip-board. Use CTRL+V to paste."
	else 
	   echo -e "please run \$ sudo apt install xclip \n"
	fi
	echo ""
	read -n 1 -s -r -p "Press any key to continue..."
}
pick_option
