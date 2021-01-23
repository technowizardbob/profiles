cmd() {
	IFSOLD=$IFS
	IFS=','
    while read -r label user_command desc; 
    do
       [[ $label =~ ^#.* ]] && continue
       [[ "$command" == "$label" ]] && break
    done < "${_RUN_CMDS_FILE}"
    IFS=$IFSOLD
    [[ "$command" == "$label" ]] && { eval "$user_command"; return; }
}
