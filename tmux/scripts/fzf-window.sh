#!/usr/bin/env bash

# fzf window selector for tmux
# Allows fuzzy selection and switching to tmux windows

if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found. Please install fzf to use this script."
    exit 1
fi

# Get list of tmux windows with their details
windows=$(tmux list-windows -F "#{window_index}: #{window_name} #{window_flags} - #{pane_current_path}")

if [[ -z "$windows" ]]; then
    echo "No tmux windows found"
    exit 1
fi

# Use fzf to select a window
selected_window=$(echo "$windows" | fzf \
    --height=40% \
    --reverse \
    --border \
    --prompt="Select window: " \
    --header="Choose a tmux window to switch to" \
    --bind='enter:accept,esc:cancel')

if [[ -n "$selected_window" ]]; then
    # Extract window index (first part before the colon)
    window_index=$(echo "$selected_window" | cut -d':' -f1)
    # Switch to the selected window
    tmux select-window -t "$window_index"
else
    echo "No window selected"
    exit 1
fi