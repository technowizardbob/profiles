install_help="
${BLD}sshto$DEF requires that the package '${GRN}%b$DEF' is installed.
Type this into the terminal and press return:

    ${BLD}%b$DEF

Then run ${BLD}sshto$DEF again
"
how_to_install() {
    local package=$1
    which yum     &> /dev/null && installer="yum -y install $package"
    which brew    &> /dev/null && installer="brew install $package"
    which apt-get &> /dev/null && installer="apt-get install -y $package"
    printf -- "$install_help" "$package" "$installer"
    [[ $2 ]] && exit $2
}
