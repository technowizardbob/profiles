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
CAP=$(echo "${SPC}${tpwd}${EPC}" | fold -w1 | shuf | tr -d '\n')
echo $CAP
if command -v xclip > /dev/null 2>&1; then
   echo $CAP | xclip -selection clipboard
#else sudo apt install xclip
fi
echo ""
