pause() { printf "\n${BLD}"; read -p 'press any key to continue'; printf "\n${DEF}"; }
line() { printf -v LINE "%$2s"; printf -- "${LINE// /$1}"; } 
