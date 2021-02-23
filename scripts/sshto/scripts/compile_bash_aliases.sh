#!/bin/bash

_PROFILES_PATH="/opt/profiles"

pushd ${_PROFILES_PATH}
tar -zvcf scripts/sshto/bin/bash_aliases.tar.gz .bashrc .bash_aliases .git_bash_prompt theme aliases/ cheats/ custom_aliases/
popd
