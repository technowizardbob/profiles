copy_files () {
    filename=$(dialog --ok-label "COPY" --cancel-label "BACK" --output-fd 1 --aspect 100 --colors --fselect $PWD/ 10 80)
	case $filename:$? in
        $PWD|$PWD/:0) return;;
                 *:0) scp -r $SSH_OPT $filename $target:~;;
                 *:*) return;;
	esac;             copy_files
}
