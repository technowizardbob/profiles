update_hosts() {

    fullist=()
    content=()

    IFSOLD=$IFS 
    IFS=$'\n' 

    for host in $(grep -h "Host " ~/.ssh/config* | sed '/\*/d; s/Host //g;'); {

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
                length=$[ (40-${#name})/2 ]
                name=$( line - $length; printf  "$name"; line - $length )
                [[ ${#name} -lt 40 ]]  &&  name=-$name
                content+=( "$desc" )
                desc=$(line - 20);;
            '#'*) continue;;
        esac

        fullist+=( "$name" "${desc/s-/}" ) #Add HostName and Description to the list

    } 

  IFS=$IFSOLD

  list=( "${fullist[@]}" )
  [[ -e \$tmpfile ]] && . \$tmpfile
  [[ $filter ]] && new_list

}

update_hosts
main_dialog
is_done
