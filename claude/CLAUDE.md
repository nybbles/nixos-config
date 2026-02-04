# User-Wide Claude Code Instructions

## Terminal Window Title

Keep the terminal window title updated to help identify this session among multiple tabs.

**When to update the title:**
- At the start of a conversation, once you understand what the user is working on
- When the conversation topic shifts significantly to a new task

**How to update:**
Use the `set-window-title` skill or run:
```bash
# Inside tmux
tmux rename-window -t "$TMUX_PANE" "SHORT DESCRIPTION"

# Regular terminal
printf '\033]0;SHORT DESCRIPTION\007'
```

Keep titles short (3-6 words), lowercase, and descriptive of the current task.
