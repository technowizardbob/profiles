is_done() {
  what=$(/opt/profiles/scripts/display_check.sh)
  [[ $what == "" ]] && clear || echo $what 
  [[ $(uname -s) == "Darwin" ]] && ls -G || ls --color=auto
  exit 0; 
}
trap is_done INT
