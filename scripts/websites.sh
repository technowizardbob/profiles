#!/bin/bash

urls=/opt/profiles/sites/urls
WEBSITE_BROWSER='firefox'

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
   done < "$urls"
   IFS=$IFSOLD
}

run_site() {
   IFSOLD=$IFS
   IFS=',';
   while read -r label mycommand desc;
   do
	[[ "$label" = "$command" ]] && {
		$WEBSITE_BROWSER "$mycommand" &
		clear
		exit 0
	}
   done < "$urls"
   IFS=$IFSOLD
}

run_dialog() {
	refresh
	command=$(dialog --ok-label "View Site" --cancel-label "EXIT" --output-fd 1 \
                    --colors \
                    --menu "Select web site:" 0 0 0 "${cmdlist[@]}")
	run_site
}

what=$(/opt/profiles/scripts/display_check.sh)
[[ $what == "" ]] && clear || { echo $what; exit 1; }

run_dialog
clear
