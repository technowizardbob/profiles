#!/bin/bash

PWD_SIZE=$((9 + RANDOM % 16)) # Min 9, Max 9 + 16

PCS='@#%^&*()_-+=[].,;:?'
SPC=${PCS:$((RANDOM % ${#PCS})):1}   # Start Random special char.
EPC=${PCS:$((RANDOM % ${#PCS})):1}   # End Random special char.

export LC_ALL=C

tpwd=$(grep -ao '[A-Za-z0-9]' /dev/urandom \
    | head -n $PWD_SIZE \
    | shuf \
    | tr -d 'ioIOlL01\n')
# Check if the variable contains a digit
if [[ ! $tpwd =~ [0-9] ]]; then
    # Generate a random number from 2 to 99
    random_number=$((RANDOM % 98 + 2))
    # Append the random number to the variable
    tpwd="${tpwd}${random_number}"
fi
CAP=$(echo "${SPC}${tpwd}${EPC}" | fold -w1 | shuf | tr -d '\n')
echo $CAP
if command -v xclip > /dev/null 2>&1; then
   printf "%s" "${CAP//$'\n'/}" | xclip -selection clipboard
   echo -e "This Password has been saved to the clip-board. Use CTRL+V to paste."
else 
   echo -e "please run \$ sudo apt install xclip \n"
fi
echo ""
read -n 1 -s -r -p "Press any key to continue..."
