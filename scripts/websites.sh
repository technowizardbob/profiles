#!/bin/bash

urls=/opt/profiles/sites/urls
WEBSITE_BROWSER='firefox'

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
	[[ "$label" = "$command" ]] && $WEBSITE_BROWSER "$mycommand" &
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

run_dialog
clear
