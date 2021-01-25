gui() { 
  clear
 
  if [ -x /usr/bin/nautilus ]; then
      /usr/bin/nautilus "sftp://${target}/home/" & 
      return 0
  fi

  if [ -x /usr/bin/dolphin ]; then
      /usr/bin/dolphin "sftp://${target}/home/" &
      return 0
  fi

  if [ -x /usr/bin/konqueror ]; then
      /usr/bin/konqueror "sftp://${target}/home/" &
      return 0
  fi

  if [ -x /usr/bin/nemo ]; then
      /usr/bin/nemo "sftp://${target}/home/" &
      return 0
  fi

  if [ -x /usr/bin/thunar ]; then
      /usr/bin/thunar "sftp://${target}/home/" &
      return 0
  fi

  if [ -x /usr/bin/caja ]; then
      /usr/bin/caja "sftp://${target}/home/" &
      return 0
  fi

  if [ -x /usr/bin/xdg-open ]; then 
     /usr/bin/xdg-open "sftp://${target}/home/" &
     return 0
  fi

  echo "Unable to find GUI File Manager"
  exit 1  
}
