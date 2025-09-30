#!/usr/bin/env bash

# gh-pr-checkout.sh - Checkout a PR branch locally
# Usage: gh-pr-checkout.sh <PR_NUMBER> <REPO_NAME> <REPO_OWNER>

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

# Show current status
echo "🔄 Checking out PR #${PR_NUMBER} from ${EXPECTED_REPO}..."

# Fetch latest changes to ensure we have the PR ref
git fetch origin >/dev/null 2>&1

# Checkout the PR using gh cli (this handles remote branch creation automatically)
if gh pr checkout "$PR_NUMBER" 2>/dev/null; then
    BRANCH_NAME=$(git branch --show-current)
    echo "✅ Successfully checked out PR #${PR_NUMBER}"
    echo "   Branch: ${BRANCH_NAME}"
    echo "   Repository: ${EXPECTED_REPO}"
    
    # Update tmux window name to include PR info
    if [[ -n "$TMUX" ]]; then
        tmux rename-window "PR#${PR_NUMBER}-${BRANCH_NAME}"
    fi
else
    echo "❌ Failed to checkout PR #${PR_NUMBER}"
    echo "   This might happen if:"
    echo "   - The PR doesn't exist"
    echo "   - You don't have permission to access it"
    echo "   - The branch is already checked out"
    exit 1
fi