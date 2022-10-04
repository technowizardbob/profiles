#!/bin/bash
if [ $(which gpg2 | wc -l) -eq 1 ]; then
   gpg2 --expert --full-generate-key
else
   source gpg_helper.sh
fi
