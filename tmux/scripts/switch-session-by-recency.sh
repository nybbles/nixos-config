#!/usr/bin/env bash
# Switch to a session using fzf, ordered by most recently active

# Source tmux-fzf environment to get $TMUX_FZF_BIN, $TMUX_FZF_OPTIONS, preview
source "$HOME/.config/tmux/plugins/tmux-fzf/scripts/.envs"

# Get current session to exclude it from the list
current_session=$(tmux display-message -p '#S')

# List sessions sorted by recency (most recently active first)
# session_activity is a Unix timestamp of last activity
# Format must be "#S: ..." for tmux-fzf's .preview-session to parse correctly
sessions=$(tmux list-sessions -F "#{session_activity} #S: #{session_windows} windows" | \
  sort -rn | \
  cut -d' ' -f2- | \
  grep -v "^${current_session}: ")

if [ -z "$sessions" ]; then
  tmux display-message "No other sessions"
  exit 0
fi

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --no-sort --header='Switch session (recent first)'"
target=$(printf "%s\n" "$sessions" | \
  eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_SESSION_OPTIONS" | \
  sed 's/:.*$//') || true

if [ -n "$target" ]; then
  tmux switch-client -t "$target"
fi

exit 0
