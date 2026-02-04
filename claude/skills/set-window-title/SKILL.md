---
name: set-window-title
description: Set the terminal window title to describe the current conversation topic. Use this proactively at the start of conversations and when the topic changes significantly. Helps the user identify terminal tabs when working with multiple Claude Code sessions.
allowed-tools: Bash(tmux rename-window *), Bash(printf *)
---

# Set Terminal Window Title

Set the terminal window/tab title to help the user identify this conversation.

## When to Use

- At the start of a conversation once you understand what the user is working on
- When the conversation topic shifts significantly
- When the user explicitly asks to update the title

## How to Set the Title

First check if running inside tmux by checking if `$TMUX` environment variable is set.

**If inside tmux** (`$TMUX` is set):

```bash
tmux rename-window -t "$TMUX_PANE" "YOUR_TITLE_HERE"
```

**If in a regular terminal** (`$TMUX` is not set):

```bash
printf '\033]0;%s\007' "YOUR_TITLE_HERE"
```

## Title Guidelines

- Keep titles short (3-6 words max)
- Use lowercase with spaces or hyphens
- Describe the task, not the tool (e.g., "auth refactor" not "claude code")
- Be specific enough to distinguish from other sessions

## Examples

Good titles:
- `fix login bug`
- `add user auth`
- `nix config updates`
- `api rate limiting`
- `pr review #42`

Bad titles:
- `helping user` (too vague)
- `working on the authentication system refactor project` (too long)
- `Claude Code Session` (not descriptive of the task)
