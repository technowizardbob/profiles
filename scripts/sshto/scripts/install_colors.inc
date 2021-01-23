colors () { 
	[[ ! -e ~/.dialogrc ]] && { dialog --create-rc ~/.dialogrc; }
    $EDITOR ~/.dialogrc
}
