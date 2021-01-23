dialog &> /dev/null || {
    [[ $(uname -s) == "Darwin" ]] \
        && echo -e "\nInstall dialog\nbrew install -y dialog" \
        || echo -e "\nInstall dialog\nsudo apt-get install -y dialog"
    exit 1
}
