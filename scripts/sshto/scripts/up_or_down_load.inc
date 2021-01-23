serverpath () { 
    new_path=$(dialog --ok-label "CHANGE" --cancel-label "BACK" --output-fd 1 --max-input 100 \
                       --aspect 100 --colors --inputbox 'Change Server folder' 10 50 $DEST)
    DEST=${new_path:-$DEST}
}

upload () {
    filelist=( $(ls -sh1 $PWD | awk '{print $2,$1}') )
	filename=$(dialog --output-fd 1 --ok-label "UPLOAD" --cancel-label "BACK" \
                      --menu "Select file\folder to upload:" 0 0 0 "${filelist[@]:2}")
	case $filename:$? in
                 *:0) [[ $filename ]] && clear; scp -r $SSH_OPT $filename $target:$DEST/;;
                 *:*) return;;
	esac;
	upload
}

dlst () { clear; filelist=( $(ssh $SSH_OPT $target ls -sh1 $DEST | awk '{print $2,$1}') ) || run_dialog; }
down () {
	filename=$(dialog --output-fd 1 --ok-label "DOWNLOAD" --cancel-label "BACK" \
                      --menu "Select file\folder to download:" 0 0 0 "${filelist[@]:2}")
	case $filename:$? in
                 *:0) [[ $filename ]] && clear; scp -r $SSH_OPT $target:$DEST/$filename .;;
                 *:*) return;;
	esac;             
	down
}
