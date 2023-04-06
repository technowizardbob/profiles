new_ssh_yes(){
    local hostname=$target
    local fprint=($(ssh-keyscan -H "$hostname" 2>/dev/null))
    grep -q "${fprint[2]}" "$knwhosts" || echo "${fprint[@]}" >> "$knwhosts"
}

fix_id(){
    clear
    hostname=$(D "FIX" '' "BACK" '' --max-input 20 --inputbox 'Change Server Host name/address' 10 30 $target)
	case $hostname:$? in
                 *:0) USEHOST=${hostname:-$USEHOST}; clear
                 local address=$(dig +short $USEHOST)
                 ssh-keygen -f "$knwhosts" -R "$USEHOST"
                 ssh-keygen -f "$knwhosts" -R "$address";;
                 *:*) return;;
	esac
     
    new_ssh_yes
    pause
}
