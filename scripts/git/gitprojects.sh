#!/bin/bash

if [ -z "$_PROFILES_PATH" ]; then
   _MAIN_PATHGP=/opt/profiles/scripts/
else
   _MAIN_PATHGP=${_PROFILES_PATH}scripts/
fi

git_projects=~/.gitprojects
tmp_projects=/tmp/gitprojects
git_util=${_MAIN_PATHGP}git/dogit
git_gen=${_MAIN_PATHGP}locate_gits.sh

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

is_valid() {
  $git_gen
  ggs=$?
  if [ "$ggs" -eq "0" ]; then
     mv $tmp_projects $git_projects
  else
     exit 1
  fi
}
opps=false
if [ ! -r "$git_projects" ]; then
   is_valid
   opps=true
fi

refresh

if [ "${#cmdlist[@]}" -eq "0" ] && [ "$opps" = false ]; then
   is_valid
   refresh
fi

clear

dialog &> /dev/null || {
    [[ "$(uname -s)" == "Darwin" ]] && \
       echo -e "\nInstall dialog\nbrew install -y dialog"
    if [[ -x /usr/bin/apt-get ]]; then
       echo -e "\nInstall dialog\nsudo apt-get install -y dialog"
    fi
    if [[ -x /usr/bin/pacman ]]; then
       echo -e "\nInstall dialog\nsudo pacman -S dialog"
    fi
    exit 1
}

edit() {
    nano "$git_projects"
    run_dialog
}

quit() { clear; exit 0; }

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
    command=$(dialog --ok-label "Pull/Push" --cancel-label "EXIT" --output-fd 1 \
                    --extra-button    --extra-label "Edit" --colors \
                    --menu "Select git project:" 0 0 0 "${cmdlist[@]}")
    case $command:$? in
         *:0) run_site;;
         *:3) edit;;
         *:*) quit;;
    esac
}

what=$(${_MAIN_PATHGP}display_check.sh)
[[ "$what" == "" ]] && echo "" || { echo "$what"; exit 1; }

run_dialog

clear

if [ -n "$DO" ]; then
 $git_util "$DO"
fi
