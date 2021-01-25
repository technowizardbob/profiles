#!/bin/bash

git_projects=~/.gitprojects
git_util='/opt/profiles/scripts/git/dogit'

if [ ! -r $git_projects ]; then
   echo "#Name,Path_to_project,short desc." > $git_projects
   nano $git_projects
fi

clear

dialog &> /dev/null || {
    [[ $(uname -s) == "Darwin" ]] && \
       echo -e "\nInstall dialog\nbrew install -y dialog"
    if [[ -x /usr/bin/apt-get ]]; then
       echo -e "\nInstall dialog\nsudo apt-get install -y dialog"
    fi
    if [[ -x /usr/bin/pacman ]]; then
       echo -e "\nInstall dialog\nsudo pacman -S dialog"
    fi
    exit 1
}

refresh() {
   cmdlist=()
   IFSOLD=$IFS
   IFS=',';
   while read -r label mycommand desc;
   do
	[[ $label =~ ^#.* ]] && continue
        cmdlist+=("$label" "$desc")
   done < "$git_projects"
   IFS=$IFSOLD
}

run_site() {
   IFSOLD=$IFS
   IFS=',';
   while read -r label mycommand desc;
   do
	[[ "$label" = "$command" ]] && DO=$mycommand
   done < "$git_projects"
   IFS=$IFSOLD
}

run_dialog() {
	refresh
	command=$(dialog --ok-label "Pull/Push" --cancel-label "EXIT" --output-fd 1 \
                    --colors \
                    --menu "Select git project:" 0 0 0 "${cmdlist[@]}")
	clear
	run_site
}

what=$(/opt/profiles/scripts/display_check.sh)
[[ $what == "" ]] && echo "" || { echo $what; exit 1; }

run_dialog
if [ ! -z $DO ]; then
 $git_util "$DO"
fi
