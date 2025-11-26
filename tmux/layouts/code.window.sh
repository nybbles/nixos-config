#!/usr/bin/env bash
# Tmuxifier window layout for coding workflow

# Set window root path
window_root "~/workbench"

# Create new window
new_window "code"

# Split the window horizontally (50% width)
split_h 50

# In the left pane, split vertically
select_pane 0
split_v 50

# In the top-left pane, split horizontally again
select_pane 0
split_h 50

# Set up each pane
# Pane 0: Commands (top-left-left)
select_pane 0

# Pane 1: Git status (top-left-right)
select_pane 1
run_cmd "lazygit"

# Pane 2: Unit tests (bottom-left)
select_pane 2

# Pane 3: Main coding area (right side)
select_pane 3

# Focus on the main coding pane by default
select_pane 3