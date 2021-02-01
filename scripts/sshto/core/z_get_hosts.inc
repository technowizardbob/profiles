zpath=$1

update_hosts() {
    if [ -z "$zpath" ]; then
        local cf=~/.ssh/config*
    else
        local cf=~/.ssh/configs_$zpath*.conf
    fi
    
    fullist=() # define & Refresh!
    content=()

    IFSOLD=$IFS 
    IFS=$'\n' 

    for host in $(grep -h "Host " $cf | sed '/\*/d; s/Host //g;'); do

        name="${host// #*/}" # Get HostName
        desc="${host//*#/}"  # Get Description

        case $desc in
            'ignore') continue;;
        esac    

        case $name in
            '#Group')
                desc="${host%\#*}"
                desc="${desc##*\#}"
                name="{ $desc }" 
                length=$(( (40-${#name})/2 ))
                name=$( line - $length; printf "%s" "$name"; line - $length )
                [[ ${#name} -lt 40 ]]  &&  name=-$name
                content+=( "$desc" )
                desc=$(line - 20);;
            '#'*) continue;;
        esac

        desc="${desc/s-/}"
        desc="${desc/ssh-/}"
        desc="${desc/h-/}"
        desc="${desc/host-/}"
        
        fullist+=( "$name" "$desc" ) #Add HostName and Description to the list

  done

  IFS=$IFSOLD

  list=( "${fullist[@]}" )
  [[ -e "$tmpfile" ]] && . "$tmpfile"
  [[ "$filter" ]] && new_list

}

update_hosts
main_dialog
is_done
