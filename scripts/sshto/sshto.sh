#!/bin/bash

errors="0"

if [ -z "$_PROFILES_PATH" ]; then
   export _MAIN_PATH_SSHTO=/opt/profiles/scripts/sshto/
else
   export _MAIN_PATH_SSHTO=${_PROFILES_PATH}scripts/sshto/
fi
_PATH_TO_CORE=${_MAIN_PATH_SSHTO}core
_CORE_FILES=${_PATH_TO_CORE}/*.inc

_PATH_TO_SCRIPTS=${_MAIN_PATH_SSHTO}scripts
_SCRIPT_FILES=${_PATH_TO_SCRIPTS}/*.inc

_RUN_CMDS_FILE=${_PATH_TO_SCRIPTS}/sshto_run_cmds.list

[ ! -f "$_RUN_CMDS_FILE" ] && { echo "No config file!! Aborting..."; exit; } 

source "${_MAIN_PATH_SSHTO}config.inc"

source "${_PATH_TO_CORE}/dynamic/run_cmd.inc"

for s in $_SCRIPT_FILES; do
    source "$s"
done

for f in $_CORE_FILES; do
    source "$f"
done
