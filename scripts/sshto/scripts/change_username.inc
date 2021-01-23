username () {
    new_user=$(dialog --ok-label "CHANGE" --cancel-label "BACK" --output-fd 1 --max-input 20 \
                        --aspect 100 --colors --inputbox 'Change alternative username' 10 30 $GUEST)
	case $new_user:$? in
                 *:0) GUEST=${new_user:-$GUEST}; SSH_OPT="-oUser=$GUEST"; USERNOTE="Username changed to \Z2$GUEST\Z0.";;
                 *:*) return;;
	esac
}
