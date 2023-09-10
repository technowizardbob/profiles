export _PROFILES_PATH="/opt/profiles/"
_CUSTOM_ENV_PATH="${_PROFILES_PATH}custom_aliases/"
_CUSTOM_ENV_FILES="${_CUSTOM_ENV_PATH}*.env"
_ENV_PATH="${_PROFILES_PATH}aliases/"
_ENV_FILES="${_ENV_PATH}*.env"

# Check if any files have changed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
source "${_PROFILES_PATH}scan_aliases.sh"

renew_env_aliases() {
    ALLENVS=()
    
    anyexists=$(ls -l $_CUSTOM_ENV_FILES 2> /dev/null | wc -l)
        
    for eev in $_ENV_FILES; do
        skip=false
        if [ ! $anyexists -eq 0 ]; then 
           for cev in $_CUSTOM_ENV_FILES; do
              if [ $(basename $cev) == $(basename "$eev") ]; then
                 skip=true
                 break
              fi   
           done
        fi   
        if [ $skip = false ]; then
           ALLENVS+=( "$eev" )
        fi
    done
    
    if [ ! $anyexists -eq 0 ]; then 
       for addce in $_CUSTOM_ENV_FILES; do
           ALLENVS+=( "$addce" )
       done
    fi
}

# List these alias Commands, this file...
cmds() {
    echo "..." > /tmp/commands.txt
    renew_env_aliases
    for f in ${ALLENVS[@]}; do
        if [ "$f" == "/opt/profiles/aliases/kubectl-cheat-sheet.env" ]; then
            # skip large file
            continue
        fi
        echo "Reading Aliases for ${f}" >> /tmp/commands.txt
        cat "${f}" >> /tmp/commands.txt
    done
    less /tmp/commands.txt
}
cmd() {
    if [ -z $1 ]; then
        renew_env_aliases
        for c in ${ALLENVS[@]}; do
            cbasename=$(basename $c)
            echo "${cbasename/.env/}"
        done
    elif [ "$1" = "?" ] ||  [ "$1" = "-help" ] ||  [ "$1" = "--help" ]; then
echo "cmd without any arugments will list all alias files.
Type: cmd followed by name of alias to list contents of.
cmd aliasfilename --edit  Will edit the alias" 
    else 
        if [ "$1" = "--edit" ] && [ -n "$2" ]; then
           local cname=$2
        elif [ "$2" = "--edit" ]; then
           local cname=$1
        fi
        if [ -z "$cname" ]; then
           local cname=$1
	   local cto=less
        else
           local cto=$EDITOR
        fi
            renew_env_aliases
            for c in ${ALLENVS[@]}; do
                cbasename=$(basename $c)
                if [ "${cbasename/.env/}" == "${cname/.env/}" ] && [ -f "$c" ]; then
                    $cto "$c"
                fi
            done
    fi
}
# Run source on file if no changes!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if [ $SANE_TEST_FAILED -eq 0 ]; then
	renew_env_aliases
	for rea in ${ALLENVS[@]}; do
		source "${rea}"
	done
fi
