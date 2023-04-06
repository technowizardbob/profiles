mosh() {
  clear
  
  if [ -x /usr/bin/mosh ]; then
     /usr/bin/mosh "$target"
  else 
     echo "Unable to find the mosh client!"
     how_to_install mosh
     exit 1 
  fi
}
