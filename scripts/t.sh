#!/bin/bash

if [ ! -d ~/.tmux/plugins/tpm ]; then
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Create a new session named "myCode"
tmux new-session -d -s myCode

# Split the window vertically
tmux split-window -v

# Split the first pane horizontally
# tmux split-pane -h -t myCode:1.1

#tmux send-keys -t myCode:1.1 'clear' C-m
tmux send-keys -t myCode:1.2 'gpcd' C-m
tmux select-pane -t myCode:1.1

tmux rename-window -t 1 "main"
tmux new-window -n "ssh"

# Window 2, Panel 1, type/run sshto
tmux send-keys -t myCode:2.1 'sshto' C-m
# Back to main Window
tmux select-window -t 1

# Attach to the session
tmux attach-session -t myCode
