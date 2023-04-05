new_ssh_yes(){
    local hostname=$target
    local fprint=($(ssh-keyscan -H "$hostname" 2>/dev/null))
    grep -q "${fprint[2]}" "$knwhosts" || echo "${fprint[@]}" >> "$knwhosts"
}

fix_id(){
    clear
    local hostname=$target
    local address=$(dig +short $hostname)
    ssh-keygen -f "$knwhosts" -R "$hostname"
    ssh-keygen -f "$knwhosts" -R "$address"
    new_ssh_yes
    pause
}
