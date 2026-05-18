#!/bin/bash

# Copy this file to ~/code/tmux-startup.config.sh and customize.

SESSION="dev"

bootstrap_session() {
  tmux new-session -d -s "${SESSION}" -n "project-1" -c "$HOME/code/project-1"
  tmux new-window -t "${SESSION}:2" -n "project-2" -c "$HOME/code/project-2"

  tmux new-window -t "${SESSION}:3" -n "notes" -c "$HOME/code/notes"
  tmux send-keys -t "${SESSION}:3" "nvim $HOME/code/notes/journal.md" C-m

  tmux new-window -t "${SESSION}:4" -n "dev-notes" -c "$HOME/code/notes"
  tmux send-keys -t "${SESSION}:4" "nvim $HOME/code/notes/dev-notes.md" C-m
  tmux split-window -t "${SESSION}:4" -h -c "$HOME/code/notes"
  tmux send-keys -t "${SESSION}:4.1" "nvim $HOME/code/notes/test-data.md" C-m

  tmux new-window -t "${SESSION}:5" -n "startup" -c "$HOME/code/notes"
  tmux split-window -t "${SESSION}:5" -h -c "$HOME/code/notes"
  tmux send-keys -t "${SESSION}:5.1" "nvim $HOME/code/notes/morning-routine.md" C-m

  tmux select-window -t "${SESSION}:5"
  tmux select-pane -t 0
}
