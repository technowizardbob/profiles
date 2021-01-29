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

        cmdlist+=("$label" "$desc")
   done <<< $hard_coded_cmds
   IFS=$IFSOLD
}

cmd() {
    IFSOLD=$IFS
    IFS=','
    while read -r label user_command desc;
    do
       [[ $label =~ ^#.* ]] && continue
       [[ "$command" == "$label" ]] && break
    done <<< $hard_coded_cmds
    IFS=$IFSOLD
    [[ "$command" == "$label" ]] && { $user_command; return; }
}
