local_port () {
    new_local=$(dialog --ok-label "CHANGE" --cancel-label "BACK" --output-fd 1 --max-input 5 \
                       --aspect 100 --colors --inputbox 'Change local port' 10 30 $LOCAL)
    LOCAL=${new_local:-$LOCAL}
}

remote_port () {
    new_remote=$(dialog --ok-label "CHANGE" --cancel-label "BACK" --output-fd 1 --max-input 5 \
                        --aspect 100 --colors --inputbox 'Change remote port' 10 30 $REMOTE)
    REMOTE=${new_remote:-$REMOTE}
}
