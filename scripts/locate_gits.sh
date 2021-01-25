#!/bin/bash
if [ ! -x /bin/locate ] && [ ! -x /usr/bin/locate ]; then
   echo "Install locate system package"
   exit 1
fi

if [ ! -x /bin/sed ] && [ ! -x /usr/bin/sed ]; then
   echo "Install sed system package"
   exit 1
fi

if [ ! -x /bin/awk ] && [ ! -x /usr/bin/awk ]; then
   echo "Install awk system package"
   exit 1
fi

list=$(locate '*/.git')

#Set the field separator to new line
OLD_IFS=$IFS
IFS=$'\n'

git_prj=/tmp/gitprojects
echo "#Name,Path_to_project,short desc." > $git_prj
for item in $list
do
	PP=$(echo $item | sed "s,/.git,,g")
        NAME=$(echo $PP | awk -F'/' '{print $(NF)}')
        echo "${NAME},${PP}," >> $git_prj
done

IFS=$OLD_IFS

nano $git_prj
