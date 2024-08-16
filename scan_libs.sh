#!/bin/bash

# Function to check the SHA-256 hash of an environment variable
check_env_var_hash() {
    local env_var_name="$1"
    local hash_file="${_PROFILES_PATH}.${env_var_name}_hash_${USER}.sum"

    # Get the current value of the specified environment variable
    local current_value=$(/usr/bin/printenv "$env_var_name")

    # Compute the SHA-256 hash of the current environment variable value
    local current_hash=$(/usr/bin/echo -n "$current_value" | $SHA_SUM_APP | /usr/bin/awk '{print $1}')

    # Check if the hash file exists
    if [[ -f "$hash_file" ]]; then
        # Read the previous hash from the file
        local previous_hash=$(/usr/bin/cat "$hash_file")
        
        # Compare the current hash with the previous hash
        if [[ "$current_hash" != "$previous_hash" ]]; then
            /usr/bin/echo -e "\033[0;31m Danger...? Change detected in $env_var_name!!! ENV VAR \033[0m"
            export SANE_TEST_FAILED=1
            return 1
        fi
    else
        /usr/bin/echo "Hash file for $env_var_name does not exist. Creating new hash file."
        # Save the current hash to the hash file
        /usr/bin/echo "$current_hash" > "$hash_file"
       if [ "$USE_SUPER" == "error" ]; then
          echo -e "Have an Admin lock down this file: $hash_file"  
          return 0
       fi
        ${USE_SUPER} chown root:root "$hash_file"
        ${USE_SUPER} chmod 444 "$hash_file"
        ${USE_SUPER} chattr +i "$hash_file"
    fi
}

check_env_var_hash "LD_PRELOAD"
check_env_var_hash "LD_LIBRARY_PATH"
check_env_var_hash "PATH"
