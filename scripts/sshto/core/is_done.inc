is_done() {
  clear
  [[ $(uname -s) == "Darwin" ]] && ls -G || ls --color=auto
  exit 0; 
}
trap is_done INT
