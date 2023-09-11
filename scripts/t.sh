#!/bin/bash

if [ ! -d ~/.tmux/plugins/tpm ]; then
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Create a new session named "myCode"
tmux new-session -d -s myCode -n main
tmux new-window -t myCode -d -n ssh

# Split the window vertically
tmux split-window -v -t myCode

tmux send-keys -t myCode:main.2 'gpcd' C-m
tmux send-keys -t myCode:ssh 'sshto' C-m

tmux select-pane -t myCode:main.1

# Attach to the session
tmux attach-session -t myCode
