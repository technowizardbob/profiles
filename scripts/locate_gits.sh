#!/bin/bash
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
