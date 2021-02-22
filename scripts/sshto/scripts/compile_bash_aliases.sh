#!/bin/bash

_PROFILES_PATH="/opt/profiles/"
_CUSTOM_ENV_PATH="${_PROFILES_PATH}custom_aliases/"
_CUSTOM_ENV_FILES="${_CUSTOM_ENV_PATH}*.env"
_ENV_PATH="${_PROFILES_PATH}aliases/"
_ENV_FILES="${_ENV_PATH}*.env"

renew_env_aliases() {
    ALLENVS=()

    anyexists=$(ls -l $_CUSTOM_ENV_FILES 2> /dev/null | wc -l)

    for eev in $_ENV_FILES; do
        skip=false
        if [ ! $anyexists -eq 0 ]; then
           for cev in $_CUSTOM_ENV_FILES; do
              if [ $(basename $cev) == $(basename "$eev") ]; then
                 skip=true
                 break
              fi
           done
        fi
        if [ $skip = false ]; then
           ALLENVS+=( "$eev" )
        fi
    done

    if [ ! $anyexists -eq 0 ]; then
       for addce in $_CUSTOM_ENV_FILES; do
           ALLENVS+=( "$addce" )
       done
    fi
}

renew_env_aliases
mkdir -p ${_PROFILES_PATH}scripts/sshto/bin > /dev/null 2> /dev/null
echo -e "# Bash aliases main\n" > ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases
echo -e "PROFILE_PATH=/opt/profiles\n_PROFILE_PATH=/opt/profiles\n" >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases
for rea in ${ALLENVS[@]}; do
    cat "${rea}" >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases
done

cat <<EOF >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases
     GIT_BRANCH_CHANGED_SYMBOL='+ changed'
     GIT_NEED_PULL_SYMBOL='⇣ do pull'
     GIT_NEED_PUSH_SYMBOL='⇡ needs push'

     BOLD="\\[\$(tput bold)\\]"
     DIM="\\[\$(tput dim)\\]"
     RESET="\\[\$(tput sgr0)\\]"
     REVERSE="\\[\$(tput rev)\\]"

        RED="\\[\\033[1;31m\\]"
     YELLOW="\\[\\033[1;33m\\]"
      GREEN="\\[\\033[0;32m\\]"
       BLUE="\\[\\033[1;34m\\]"
    MAGENTA="\\[\\033[1;35m\\]"
       CYAN="\\[\\033[1;36m\\]"
  LIGHT_RED="\\[\\033[1;31m\\]"
LIGHT_GREEN="\\[\\033[1;32m\\]"
 LIGHT_BLUE="\\[\\033[1;94m\\]"
 LIGHT_CYAN="\\[\\033[1;96m\\]"
      WHITE="\\[\\033[1;37m\\]"
      BLACK="\\[\\033[1;30m\\]"
 LIGHT_GRAY="\\[\\033[1;37m\\]"

 BK_DEFAULT="\\[\\e[49m\\]"
 BK_BLACK="\\[\\e[40m\\]"
 BK_RED="\\[\\e[41m\\]"
 BK_GREEN="\\[\\e[42m\\]"
 BK_YELLOW="\\[\\e[43m\\]"
 BK_BLUE="\\[\\e[44m\\]"
 BK_LIGHT_RED="\\[\\e[101m\\]"
 BK_LIGHT_GREEN="\\[\\e[102m\\]"
 BK_LIGHT_YELLOW="\\[\\e[103m\\]"
 BK_LIGHT_BLUE="\\[\\e[104m\\]"
 BK_LIGHT_CYAN="\\[\\e[106m\\]"
 BK_LIGHT_WHITE="\\[\\e[107m\\]"
 BK_EXIT="\\[\\e[49m\\]"

 COLOR_NONE="\\[\\e[0m\\]"
 COLOR_DEFAULT="\\[\\e[39m\\]"

function is_normal_theme() {
    if [ -f ~/.unicode_support ]; then
     PS_SYMBOL='🐧'
     SEGMENT_SEPARATOR=\$'\\ue0b0'
     PL_BRANCH_CHAR=\$'\\ue0a0'         # 
    else
     PS_SYMBOL=''
     SEGMENT_SEPARATOR=' -> '
     PL_BRANCH_CHAR=''
    fi

    if [ ! -f ~/.use_theme ]; then
        return 1
    else
        return 0
    fi
}

__git_info() {
        [ -d .git ] || return

        local aheadN
        local behindN
        local branch
        local marks
        local stats

        branch="\$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)"
        [ -n "\$branch" ] || return  # git branch not found

        stats="\$(git status --porcelain --branch | grep '^##' | grep -o '\\[.\\+\\]\$')"
        aheadN="\$(echo "\$stats" | grep -o 'ahead \\d\\+' | grep -o '\\d\\+')"
        behindN="\$(echo "\$stats" | grep -o 'behind \\d\\+' | grep -o '\\d\\+')"
        [ -n "\$aheadN" ] && marks+=" \$GIT_NEED_PUSH_SYMBOL\$aheadN"
        [ -n "\$behindN" ] && marks+=" \$GIT_NEED_PULL_SYMBOL\$behindN"

        if ! is_normal_theme; then
            printf "%s" "\$state[\$branch]\$WHITE\$marks"
           return
        fi

        # print the git branch segment without a trailing newline
        # branch is modified?
        if [ -n "\$(git status --porcelain)" ]; then
            printf "%s" "\$RESET\$bk\$WHITE[\$branch]\$marks\$state"
        else
            printf "%s" "\$RESET\$bk\$WHITE[\$branch]\$marks\$RESET\$state"
        fi
    }

function is_git_repository {
  git branch > /dev/null 2>&1
}

function set_git_branch {
  # Capture the output of the "git status" command.
  git_status="\$(git status 2> /dev/null)"

  # Set color based on clean/staged/dirty.
  if [[ \${git_status} =~ "working tree clean" ]]; then
    state="\${GREEN}"
    bk="\$BK_GREEN"
  elif [[ \${git_status} =~ "Changes to be committed" ]]; then
    state="\${YELLOW}"
    bk="\$BK_YELLOW"
  else
    state="\${RED}"
    bk="\$BK_RED"
  fi

  # Set arrow icon based on status against remote.
  remote_pattern="# Your branch is (.*) of"
  if [[ \${git_status} =~ \${remote_pattern} ]]; then
    if [[ \${BASH_REMATCH[1]} == "ahead" ]]; then
      remote="↑ needs push"
    else
      remote="↓ do pull"
    fi
  else
    remote="\$PL_BRANCH_CHAR"
  fi
  diverge_pattern="# Your branch and (.*) have diverged"
  if [[ \${git_status} =~ \${diverge_pattern} ]]; then
    remote="↕ changed"
  fi

  BRANCH="\${state}(git)\${COLOR_NONE}\${remote} "
  BRANCH+="\$(__git_info bk)"
  if is_normal_theme; then
    BRANCH+="\$BK_EXIT\${SEGMENT_SEPARATOR}\$RESET"
  fi
}

function set_prompt_symbol() {
  if is_normal_theme; then
     ERRX="✘"
  else
     ERRX="Opps!"
  fi
  if test \$1 -eq 0 ; then
      PROMPT_SYMBOL="\\\$\${COLOR_NONE}"
  else
      PROMPT_SYMBOL="\${RED}\${ERRX} \\\$\${COLOR_NONE}"
  fi
}

# Set the full bash prompt.
function set_bash_prompt() {
  set_prompt_symbol \$?
  if is_git_repository ; then
    set_git_branch
  else
    BRANCH=''
  fi
  if [ -n "\$SSH_CLIENT" ] || [ -n "\$SSH_TTY" ]; then
    UPC="\${RED}SSH:\${WHITE}"
  else
    UPC="Local:"
  fi
EOF

if [ -f "${_PROFILES_PATH}theme" ]; then
   cat "${_PROFILES_PATH}theme" >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases
else
   echo '	WD="\w${COLOR_NONE}${WHITE}"' >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases
   echo '	PS1="$CYAN$UPC ${WHITE}${BRANCH} ${WD} ${PROMPT_SYMBOL} "' >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases
fi

echo -e "}\n" >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases

echo "PROMPT_COMMAND=set_bash_prompt" >> ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases

echo "Made the following file: ${_PROFILES_PATH}scripts/sshto/bin/.bash_aliases"
