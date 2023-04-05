downpath(){
    new_path=$(D "CHANGE" '' "BACK" '' --max-input 100 --inputbox 'Change download folder' 10 50 $DEST)
    DEST=${new_path:-$DEST}
    dfilelist=
}

homepath(){
    new_path=$(D "CHANGE" '' "BACK" '' --max-input 100 --inputbox 'Change home folder' 10 50 $home)
    home=${new_path:-$home}
}

uploader(){
    printf "Uploading $BLD$filename$DEF\n"
    scp -r $SSH_OPT $filename $target:"$DEST/"
}

mountdest(){
    which sshfs &> /dev/null || { clear; how_to_install sshfs; pause; return; }
    clear
    sudo mkdir -p "/mnt/$target"
    sudo chown $USER:$USER "/mnt/$target"
	echo "Mounting in /mnt/$target"	
    sshfs $sshfsopt "$target":"$DEST" "/mnt/$target" || pause
}

unmountdest(){ mount | grep -q "$target" && umount "/mnt/$target"; }

upload(){
    filelist=( $(ls -sh1 $home | awk '{print $2,$1}') )
	filename=$(D "UPLOAD" '' "BACK" '' --menu "Select file\folder to upload:" 0 0 0 "${filelist[@]:2}")
	case $? in
         0) [[ $filename ]] || upload
            clear; uploader; pause;;
         *) return;;
	esac;   upload
}

download(){
	clear
    [[ $dfilelist ]] || {
        dfilelist=$(ssh $SSH_OPT $target ls -sh1 $DEST 2>&1) \
            && dfilelist=( $(awk '{print $2,$1}' <<< "$dfilelist") ) \
            || {
                clear
                echo "$dfilelist"
                pause
                dfilelist=
                run_dialog
            }
    }
	dfilename=$(D "DOWNLOAD" '' "BACK" '' --menu "Select file\folder to download:" 0 0 0 "${dfilelist[@]:2}")
	case $? in
         0) [[ $dfilename ]] || download
            clear
            printf "Downloading $BLD$dfilename$DEF\n"
            scp -r $SSH_OPT $target:"$DEST/$dfilename" . || pause;;
         *) return;;
	esac;   download
}
