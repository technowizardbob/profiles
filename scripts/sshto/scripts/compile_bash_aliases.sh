#!/bin/bash

if [ -z "$_PROFILES_PATH" ]; then
   _PROFILES_PATHA=/opt/profiles/
else
   _PROFILES_PATHA=${_PROFILES_PATH}
fi

if [ ! -d ${_PROFILES_PATHA} ]; then
   echo "Sorry, no /opt/profiles folder!"
   exit 1
fi

_MAIN_PATH="${_PROFILES_PATHA}scripts/sshto"

if [ ! -d ${_MAIN_PATH}/bin ]; then
   mkdir -p ${_MAIN_PATH}/bin > /dev/null 2> /dev/null
   chmod 775 ${_MAIN_PATH}/bin
fi

pushd ${_PROFILES_PATHA}
tar -zvcf ${_MAIN_PATH}/bin/bash_aliases.tar.gz .bashrc .bash_aliases .git_bash_prompt theme aliases/ cheats/ custom_aliases/ scripts/pwd_gen.sh
popd
