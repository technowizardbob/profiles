#!/bin/bash

_MAIN_PATH="/opt/profiles/scripts/sshto"

_SSHTO_BIN=${_MAIN_PATH}/bin/sshto   

_PATH_TO_CORE="${_MAIN_PATH}/core"
_CORE_FILES="${_PATH_TO_CORE}/*.inc"

_PATH_TO_SCRIPTS="${_MAIN_PATH}/scripts"
_SCRIPT_FILES="${_PATH_TO_SCRIPTS}/*.inc"

_RUN_CMDS_FILE="${_PATH_TO_SCRIPTS}/sshto_run_cmds.list" 

[ ! -f $_RUN_CMDS_FILE ] && { echo "No config file!! Aborting..."; exit; } 

echo "#!/bin/bash" > $_SSHTO_BIN
cat ${_MAIN_PATH}/config.inc >> $_SSHTO_BIN
echo -e "\n" >> $_SSHTO_BIN
echo "_RUN_CMDS_FILE=\"/etc/sshto_run_cmds.list\"" >> $_SSHTO_BIN
echo "tmpfile=/tmp/sshtorc" >> $_SSHTO_BIN
echo "[[ -e \$tmpfile ]] && . \$tmpfile" >> $_SSHTO_BIN

echo -e "#run_cmd.inc: \n" >> $_SSHTO_BIN
echo "cmd() {" >> $_SSHTO_BIN
IFSOLD=$IFS
IFS=','
while read -r label user_command desc; 
do
  [[ $label =~ ^#.* ]] && continue
  echo "[[ \"\$command\" == \"$label\" ]] && { $user_command; return; }" >> $_SSHTO_BIN
done < "${_RUN_CMDS_FILE}"
IFS=$IFSOLD
echo "}" >> $_SSHTO_BIN # end run_cmd.inc

for s in $_SCRIPT_FILES;
do
	echo -e "#script: $s \n" >> $_SSHTO_BIN
	cat $s >> $_SSHTO_BIN
done

for f in $_CORE_FILES;
do
	echo -e "#core: $f \n" >> $_SSHTO_BIN
	cat $f >> $_SSHTO_BIN
done

set -x
chmod 755 $_SSHTO_BIN
chmod 644 $_RUN_CMDS_FILE
[ -f /etc/sshto_run_cmds.list ] && sudo rm /etc/sshto_run_cmds.list
[ -f /usr/local/bin/sshto ] && sudo rm /usr/local/bin/sshto
sudo cp $_RUN_CMDS_FILE /etc/sshto_run_cmds.list
sudo cp $_SSHTO_BIN /usr/local/bin/
set +x
echo -e "Compiled \n"
