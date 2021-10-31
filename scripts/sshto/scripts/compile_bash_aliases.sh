#!/bin/bash

_PROFILES_PATH="/opt/profiles"

if [ ! -d ${_PROFILES_PATH} ]; then
   echo "Sorry, no /opt/profiles folder!"
   exit 1
fi

_MAIN_PATH="${_PROFILES_PATH}/scripts/sshto"

if [ ! -d ${_MAIN_PATH}/bin ]; then
   mkdir -p ${_MAIN_PATH}/bin > /dev/null 2> /dev/null
   chmod 775 ${_MAIN_PATH}/bin
fi

pushd ${_PROFILES_PATH}
tar -zvcf ${_MAIN_PATH}/bin/bash_aliases.tar.gz .bashrc .bash_aliases .git_bash_prompt theme aliases/ cheats/ custom_aliases/ scripts/pwd_gen.sh scripts/todo/
popd
