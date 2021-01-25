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

contents_menu () {
	filter=$(dialog --output-fd 1 --ok-label "SELECT" --cancel-label "BACK" \
                    --no-items --menu "Select list of hosts:" 0 0 0 "All" "${content[@]}" > /dev/tty)
	case $filter:$? in
             All:0) list=( "${fullist[@]}" );;
               *:0) new_list;; 
    esac
    main_dialog
}
