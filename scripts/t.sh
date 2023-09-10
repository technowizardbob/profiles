#!/bin/bash

# Create a new session named "myCode"
tmux new-session -d -s myCode

# Split the window vertically
tmux split-window -v

# Split the first pane horizontally
# tmux split-pane -h -t myCode:0.0

#tmux send-keys -t myCode:0.0 'clear' C-m
tmux send-keys -t myCode:0.1 'gpcd' C-m
tmux select-pane -t myCode:0.0

tmux rename-window -t 0 "main"
tmux new-window -n "ssh"

# Window 1, Panel 0, type/run sshto
tmux send-keys -t myCode:1.0 'sshto' C-m
# Back to main Window
tmux select-window -t 0

# Attach to the session
tmux attach-session -t myCode
