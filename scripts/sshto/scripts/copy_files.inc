copy_files () {
	filename=$(D "COPY" '' "BACK" '' --fselect $PWD/ 10 80)
    
	case $filename:$? in
        $PWD|$PWD/:0) return;;
                 *:0) clear; uploader; scp -r $SSH_OPT $filename $target:~;;
                 *:*) return;;
	esac;             copy_files
}
