#!/usr/bin/env bash

# gh-pr-review.sh - Open PR in Octo.nvim with adaptive tmux layout
# Usage: gh-pr-review.sh <PR_NUMBER> <REPO_NAME> <REPO_OWNER>

set -e

PR_NUMBER="$1"
REPO_NAME="$2"
REPO_OWNER="$3"

# Validate arguments
if [[ -z "$PR_NUMBER" || -z "$REPO_NAME" || -z "$REPO_OWNER" ]]; then
    echo "Error: Missing required arguments"
    echo "Usage: $0 <PR_NUMBER> <REPO_NAME> <REPO_OWNER>"
    exit 1
fi

# Check if we're in tmux
if [[ -z "$TMUX" ]]; then
    echo "Error: This script requires tmux"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get current repository info
CURRENT_REPO=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null)
EXPECTED_REPO="${REPO_OWNER}/${REPO_NAME}"

# Check if we're in the correct repository
if [[ "$CURRENT_REPO" != "$EXPECTED_REPO" ]]; then
    echo "Error: Current repository ($CURRENT_REPO) doesn't match PR repository ($EXPECTED_REPO)"
    echo "Please navigate to the correct repository first"
    exit 1
fi

# Get current working directory for new pane/window
CURRENT_DIR=$(pwd)

# Get tmux window width to decide on layout
WINDOW_WIDTH=$(tmux display-message -p '#{window_width}')
echo "🔄 Opening PR #${PR_NUMBER} from ${EXPECTED_REPO} in Octo.nvim..."

# Decide whether to use horizontal split or new window based on width
if [[ "$WINDOW_WIDTH" -ge 160 ]]; then
    # Wide enough for horizontal split
    echo "   Using horizontal split (window width: ${WINDOW_WIDTH})"
    
    # Create horizontal split (side-by-side panes)
    tmux split-window -h -c "$CURRENT_DIR"
    
    # Switch to the new pane
    tmux select-pane -R
    
    # Start nvim with Octo command
    tmux send-keys "nvim -c ':Octo pr edit ${PR_NUMBER}'" Enter
    
    # Rename the window to include PR info
    tmux rename-window "Review-PR#${PR_NUMBER}"
    
else
    # Not wide enough, create new window
    echo "   Using new window (window width: ${WINDOW_WIDTH} < 160)"
    
    # Create new window
    tmux new-window -c "$CURRENT_DIR" -n "Review-PR#${PR_NUMBER}"
    
    # Start nvim with Octo command in the new window
    tmux send-keys "nvim -c ':Octo pr edit ${PR_NUMBER}'" Enter
fi

echo "✅ Successfully opened PR #${PR_NUMBER} for review"
echo "   Use Octo.nvim commands to review the PR"
echo "   Press <C-c> to close the review tab when done"