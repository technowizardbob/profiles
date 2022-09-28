if [ -z "$_PROFILES_PATH" ]; then
   _MAIN_PATHC=/opt/profiles/scripts/
else
   _MAIN_PATHC=${_PROFILES_PATH}scripts/
fi


if [ ! -d ~/.ssh ]; then
   ${_MAIN_PATHC}gen_rsa_key.sh
fi

refresh() {
   cmdlist=()
   IFSOLD=$IFS
   IFS=',';
   while read -r label mycommand desc;
   do
        [[ $label =~ ^#.* ]] && continue
        
        desc=${desc/!GUEST/$GUEST}
        desc=${desc/!REMOTE/$REMOTE}
        desc=${desc/!LOCAL/$LOCAL}
        
        cmdlist+=("$label" "$desc" )
   done < "${_RUN_CMDS_FILE}"
   IFS=$IFSOLD
}

cmd() {
    IFSOLD=$IFS
    IFS=','
    while read -r label user_command desc;
    do
       [[ $label =~ ^#.* ]] && continue
       [[ "$command" == "$label" ]] && break
    done < "${_RUN_CMDS_FILE}"
    IFS=$IFSOLD
    [[ "$command" == "$label" ]] && { $user_command; return; }
}
