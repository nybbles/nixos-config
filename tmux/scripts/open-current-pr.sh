#!/usr/bin/env bash

# open-current-pr.sh - Open the current branch's PR in gh.nvim
# Usage: open-current-pr.sh

set -e

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get PR number for current branch
echo "🔍 Looking for PR associated with current branch..."
PR_NUMBER=$(gh pr view --json number --jq '.number' 2>/dev/null)

if [[ -z "$PR_NUMBER" || "$PR_NUMBER" == "null" ]]; then
    CURRENT_BRANCH=$(git branch --show-current)
    echo "❌ No PR found for current branch: $CURRENT_BRANCH"
    echo "   Make sure you're on a branch that has an associated PR"
    exit 1
fi

CURRENT_REPO=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null)
echo "✅ Found PR #${PR_NUMBER} in ${CURRENT_REPO}"

# Launch nvim with gh.nvim command directly
echo "🚀 Opening PR #${PR_NUMBER} in gh.nvim..."
nvim -c ":GHOpenPR ${PR_NUMBER}"