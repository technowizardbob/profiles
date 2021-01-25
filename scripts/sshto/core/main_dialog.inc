main_dialog () {
	target=$(dialog --extra-button --extra-label "RUN COMMAND"         \
					--ok-label "CONNECT" --cancel-label "EXIT" --colors \
                    --help-button --help-label  "CONTENTS" --output-fd 1 \
					--menu "Select host to connect to. $USERNOTE" 0 0 0 "${list[@]}");
	case $target:$? in
       -*\ *\ *-:*) main_dialog ;;
               *:0) go_to_target; main_dialog;;
               *:2) contents_menu;;
	       *:3) run_dialog;;
	       *:*) is_done;;
	esac
}
