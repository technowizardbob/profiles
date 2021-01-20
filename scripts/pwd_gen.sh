#!/bin/bash

PWD_SIZE=$((7 + $RANDOM % 16)) # Min 7, Max 7 + 16

PCS='!@#%^&*()_-+=[].,;:?'
SPC=${PCS:$(($RANDOM % ${#PCS})):1}   # Start Random special char.
EPC=${PCS:$(($RANDOM % ${#PCS})):1}   # End Random special char.

export LC_ALL=C

echo -e "$SPC\c"
cat /dev/urandom | grep -ao '[A-Za-z0-9]' \
    | head -n $PWD_SIZE \
    | shuf \
    | tr -d '\n'
echo $EPC
