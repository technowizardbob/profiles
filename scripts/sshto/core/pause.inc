pause() { printf "\n${BLD}"; read -n 1 -s -r -p "press any key to continue"; printf "\n${DEF}"; }
line() { printf -v LINE "%$2s"; printf -- "${LINE// /$1}"; } 
