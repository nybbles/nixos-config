#!/usr/bin/env bash
# Select a window in the current session using fzf

# Source tmux-fzf environment to get $TMUX_FZF_BIN and $TMUX_FZF_OPTIONS
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOME/.config/tmux/plugins/tmux-fzf/scripts/.envs"

# Get current window to exclude it from the list
current=$(tmux display-message -p "#I")

# List windows in current session only (no -a flag = current session)
# Exclude the current window from the list
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select window in current session'"
target=$(tmux list-windows -F "#I: #{window_name}" | \
  grep -v "^$current:" | \
  eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS" | \
  cut -d: -f1) || true  # Don't fail if fzf is cancelled

# Switch to the selected window if one was chosen
if [ -n "$target" ]; then
  tmux select-window -t "$target"
fi

# Always exit successfully (don't show "returned 1" message)
exit 0
