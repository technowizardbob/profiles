portunneling() { clear; echo -e "\nDoing Tunnel....\n"; ssh $SSH_OPT -L $REMOTE:127.0.0.1:$LOCAL -N $target; pause; }
