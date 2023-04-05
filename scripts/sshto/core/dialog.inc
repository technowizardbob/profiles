do='--output-fd 1 --colors' # dialog common options
ap='--aspect 100'			# aspect 100
eb='--extra-button'         # extra
hb='--help-button'          # buttons
cl='--cancel-label'         # and
el='--extra-label'          # short
hl='--help-label'           # label
ol='--ok-label'             # names

# Dialog buttons order and exit codes
#<OK> <Extra> <Cancel> <Help>
# 0      3       1       2

D(){ # dialog creator
    local opts=()
    [[ $1 ]] && opts+=("$ol" "$1")
    [[ $2 ]] && opts+=("$el" "$2" "$eb")
    [[ $3 ]] && opts+=("$cl" "$3")
    [[ $4 ]] && opts+=("$hl" "$4" "$hb")
    shift 4
    dialog "${opts[@]}" $do  "$@"
}
