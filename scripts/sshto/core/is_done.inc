is_done() {
  if [ "$errors" != "0" ]; then
     exit 1
  fi
  what=$(/opt/profiles/scripts/display_check.sh)
  [[ $what == "" ]] && {
        clear 
        [[ $(uname -s) == "Darwin" ]] && ls -G || ls --color=auto
        exit 0; 
  } || { echo $what; exit 1; } 
}
trap is_done INT
