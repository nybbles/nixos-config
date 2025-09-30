#!/usr/bin/env bash

# Load fzf if available
if command -v fzf >/dev/null 2>&1; then
    # Get directories from multiple sources
    {
        # From zoxide (most frequently used directories)
        if command -v zoxide >/dev/null 2>&1; then
            zoxide query -l 2>/dev/null | head -20
        fi
        
        # From home directory (common directories)
        find ~ -maxdepth 2 -type d 2>/dev/null | grep -v '/\.'
        
        # Common development paths
        find ~/code ~/projects ~/dev ~/work 2>/dev/null -maxdepth 2 -type d | head -10
        
        # Current directory and subdirectories
        find . -maxdepth 2 -type d 2>/dev/null
    } | sort -u | fzf \
        --height=40% \
        --reverse \
        --border \
        --preview='ls -la {}' \
        --preview-window=right:50% \
        --prompt="Select directory: " \
        --header="Choose a directory for tmux session" \
        --bind='enter:accept,esc:cancel' | {
        read -r selected_dir
        if [[ -n "$selected_dir" && -d "$selected_dir" ]]; then
            # Get absolute path
            abs_path=$(cd "$selected_dir" && pwd)
            # Change to the selected directory
            cd "$abs_path" || exit 1
            # Update tmux session working directory
            tmux refresh-client -S
            echo "Changed to: $abs_path"
        else
            echo "No directory selected or invalid path"
            exit 1
        fi
    }
else
    echo "fzf not found. Please install fzf to use this script."
    exit 1
fi