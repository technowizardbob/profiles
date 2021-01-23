refresh() { 
   cmdlist=()
   IFSOLD=$IFS
   IFS=',';
   while read -r label mycommand desc; 
   do
		[[ $label =~ ^#.* ]] && continue
        cmdlist+=("$label" "$desc")
   done < "${_RUN_CMDS_FILE}"
   IFS=$IFSOLD
}

run_dialog() { 
	refresh
	command=$(dialog --ok-label "RUN" --cancel-label "BACK" --output-fd 1 \
                    --extra-button    --extra-label "CONNECT" --colors    \
                    --menu "Select command to run on host \Z4$target\Z0. $USERNOTE" 0 0 0 "${cmdlist[@]}")
                    
    case $command:$? in
         *:0) cmd;;
         *:3) go_to_target;;
         *:*) main_dialog;;
	esac            
  
    run_dialog
    
}
