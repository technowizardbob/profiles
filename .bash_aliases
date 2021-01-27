_PROFILES_PATH="/opt/profiles/"
_CUSTOM_ENV_PATH="${_PROFILES_PATH}custom_aliases/"
_CUSTOM_ENV_FILES="${_CUSTOM_ENV_PATH}*.env"
_ENV_PATH="${_PROFILES_PATH}aliases/"
_ENV_FILES="${_ENV_PATH}*.env"

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
commands() {
    echo "..." > /tmp/commands.txt
    renew_env_aliases
    for f in ${ALLENVS[@]}; do
        echo "Reading Aliases for ${f}" >> /tmp/commands.txt
        cat "${f}" >> /tmp/commands.txt
    done
    less /tmp/commands.txt
}
command() {
        renew_env_aliases
        for c in ${ALLENVS[@]}; do
            cbasename=$(basename $c)
            if [ -z "$1" ]; then
                echo "${cbasename/.env/}"
            else
                if [ "${cbasename/.env/}" == "${1/.env/}" ] && [ -f "$c" ]; then
                    less "$c"
                fi
            fi
        done
}

renew_env_aliases
for rea in ${ALLENVS[@]}; do
    source "${rea}"
done
