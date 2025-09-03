#!/usr/bin/env bash

# Script to move a tmux window to a specific position
# Usage: move-window-to-position.sh <target_position>

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <target_position>"
    echo "Example: $0 3"
    exit 1
fi

target_position="$1"

# Validate input - must be a positive integer
if ! [[ "$target_position" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: Target position must be a positive integer"
    exit 1
fi

# Get current window index
current_window=$(tmux display-message -p '#I')

# Get the highest window index
max_window=$(tmux list-windows -F '#I' | sort -n | tail -1)

# Validate target position
if [[ "$target_position" -gt "$max_window" ]]; then
    # If target is beyond max, move to the end
    target_position="$max_window"
fi

# If we're already at the target position, do nothing
if [[ "$current_window" -eq "$target_position" ]]; then
    echo "Window is already at position $target_position"
    exit 0
fi

# Move window by "bubbling" through positions
if [[ "$current_window" -lt "$target_position" ]]; then
    # Moving right - swap with next windows until we reach target
    for ((i = current_window; i < target_position; i++)); do
        next=$((i + 1))
        # Check if next window exists
        if tmux list-windows -F '#I' | grep -q "^$next$"; then
            tmux swap-window -s "$i" -t "$next"
        fi
    done
else
    # Moving left - swap with previous windows until we reach target
    for ((i = current_window; i > target_position; i--)); do
        prev=$((i - 1))
        # Check if previous window exists
        if tmux list-windows -F '#I' | grep -q "^$prev$"; then
            tmux swap-window -s "$i" -t "$prev"
        fi
    done
fi

# Select the target window
tmux select-window -t "$target_position"

# Display confirmation
echo "Moved window to position $target_position"