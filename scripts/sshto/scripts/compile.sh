#!/bin/bash

_MAIN_PATH="/opt/profiles/scripts/sshto"

_SSHTO_BIN=${_MAIN_PATH}/bin/sshto   

if [ ! -d /opt/profiles ]; then
   echo "Sorry, no /opt/profiles folder!"
   exit 1
fi   

if [ ! -d ${_MAIN_PATH}/bin ]; then
   mkdir -p ${_MAIN_PATH}/bin > /dev/null 2> /dev/null
   chmod 775 ${_MAIN_PATH}/bin
fi   

_PATH_TO_CORE="${_MAIN_PATH}/core"
_CORE_FILES="${_PATH_TO_CORE}/*.inc"

_PATH_TO_SCRIPTS="${_MAIN_PATH}/scripts"
_SCRIPT_FILES="${_PATH_TO_SCRIPTS}/*.inc"

_RUN_CMDS_FILE="${_PATH_TO_SCRIPTS}/sshto_run_cmds.list" 

[ ! -f $_RUN_CMDS_FILE ] && { echo "No config file!! Aborting..."; exit; } 

echo "#!/bin/bash" > $_SSHTO_BIN
cat ${_MAIN_PATH}/config.inc >> $_SSHTO_BIN

echo -e "\n" >> $_SSHTO_BIN
echo "hard_coded_cmds=\$(cat <<EOF"  >> $_SSHTO_BIN
cat $_RUN_CMDS_FILE >> $_SSHTO_BIN
echo "EOF" >> $_SSHTO_BIN
echo -e ")\n"  >> $_SSHTO_BIN

echo -e "#script: run_cmd.inc \n" >> $_SSHTO_BIN
cat ${_PATH_TO_CORE}/static/run_cmd.inc >> $_SSHTO_BIN
echo -e "\n" >> $_SSHTO_BIN

for s in $_SCRIPT_FILES; do
    echo -e "#script: $s \n" >> $_SSHTO_BIN
    cat $s >> $_SSHTO_BIN
done

for f in $_CORE_FILES; do
    echo -e "#core: $f \n" >> $_SSHTO_BIN
    cat $f >> $_SSHTO_BIN
done

set -x
chmod 755 $_SSHTO_BIN
set +x
echo "To use: $ sudo cp $_SSHTO_BIN /usr/local/bin/"
echo -e "Compiled to: $_SSHTO_BIN \n"
