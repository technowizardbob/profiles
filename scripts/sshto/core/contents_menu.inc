new_list() {
    list=()
    match=""
    for item in "${fullist[@]}"; {
        case $item:$match in
           -*\ *\ *-:1) break;;
           -*\ $filter\ *-:*) match=1;;
        esac
        [[ $match ]] && list+=( "$item" )
    }
    [[ ${list[*]} ]] && echo "filter='$filter'" > "$tmpfile" || { list=( "${fullist[@]}" ); rm "$tmpfile"; }
}

editconfig() { nano ~/.ssh/config; update_hosts; }

contents_menu () {
	filter=$(dialog --output-fd 1 --ok-label "SELECT" --cancel-label "BACK" \
	                --extra-button --extra-label "Edit"         \
                    --no-items --menu "Select list of hosts:" 0 0 0 "All" "${content[@]}")
	case $filter:$? in
             All:0) list=( "${fullist[@]}" );;
               *:0) new_list;; 
               *:3) editconfig;;
    esac
    main_dialog
}
