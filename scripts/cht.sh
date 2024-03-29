#!/bin/bash
languages=`echo "golang lua cpp c typescript nodejs bash python3" | tr ' ' '\n'`
core_utils=`echo "xargs find mv sed awk git cmake" | tr ' ' '\n'`

selected=`printf "$languages\n$core_utils" | fzf`
read -p "query: " query

if printf $languages | grep -qs $selected; then
    curl cht.sh/$selected/`echo $query | tr ' '  '+'`
else
    curl cht.sh/$selected~$query
fi
read -p "Hit enter to exit" hit
