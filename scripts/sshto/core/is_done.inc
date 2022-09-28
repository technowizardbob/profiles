if [ -z "$_PROFILES_PATH" ]; then
   _MAIN_PATHD=/opt/profiles/scripts/
else
   _MAIN_PATHD=${_PROFILES_PATH}scripts/
fi

is_done() {
  if [ "$errors" != "0" ]; then
     exit 1
  fi
  what=$(${_MAIN_PATHD}display_check.sh)
  [[ $what == "" ]] && {
        clear 
        #echo "Edit me: ${_MAIN_PATHD}sshto/core/is_done.inc"
	echo "Cool beans..."
        # [[ $(uname -s) == "Darwin" ]] && ls -G || ls --color=auto
        exit 0; 
  } || { clear; echo $what; exit 1; } 
}
trap is_done INT
