# Claude-tmux + Twig Integration - Setup Complete

## What was installed

### 1. **claude-tmux** - Claude Code session manager
- TUI popup for managing Claude Code sessions
- Installed from: `github:nielsgroen/claude-tmux`
- Includes OpenSSL support for secure connections

### 2. **twig** - Git worktree + branch manager
- CLI for managing git worktrees with symlink support
- Installed from: `github:708u/twig` (main branch)
- Patched to work with current Go version

## How to use

### Claude-tmux

**Fastest access (no prefix):**
```
Alt+c  # Opens Claude session manager popup (90% width, 80% height)
```

**Via tmux which-key:**
```
Ctrl+a Space A  # Shows "Claude (M-c)" menu item
```

### Twig

**Command-line:**
```bash
twig init           # Initialize twig in a git repo
twig add <branch>   # Create new worktree for branch
twig list           # List all worktrees
twig remove <name>  # Remove a worktree
twig clean          # Clean up merged worktrees
twig sync           # Sync symlinks across worktrees
```

**Shell aliases (available in new shells):**
```bash
tw      # twig
twa     # twig add
twl     # twig list
twr     # twig remove
```

**Tmux which-key menu:**
```
Ctrl+a Space g      # Opens Worktrees menu
  l - List worktrees
  a - Add new worktree
  d - Remove worktree
  c - Clean merged worktrees
  s - Sync symlinks
```

**Tab completions:**
- Zsh completions are automatically loaded in new shells
- Try: `twig <TAB>` to see available commands

## Configuration

### Twig settings template

A reference template is available at:
`~/workbench/nixos-config/twig/settings.toml.template`

To use it in a project:
```bash
cd your-project
twig init
cp ~/workbench/nixos-config/twig/settings.toml.template .twig/settings.toml
# Edit .twig/settings.toml to customize for your project
```

The template includes symlink configurations for:
- Rust: `target/` directory
- Python: `.venv/`, `__pycache__/`, `.pytest_cache/`
- Go: `vendor/`
- Environment: `.env`, `.env.local`, `.direnv`
- Claude Code: `.claude/` directory

## Claude Code skill

### /update-nix-hash

A new skill is available to help fix Nix hash mismatches:

```
/update-nix-hash
```

This skill will:
1. Run `home-manager switch` to detect hash mismatches
2. Parse errors for correct hashes
3. Update `flake.nix` with the new hashes
4. Re-run to verify the fix

## Activation

To activate in current shell:
```bash
# Reload shell configuration
exec zsh

# Or manually source
source ~/.zshrc
```

To reload tmux config (already done):
```bash
tmux source-file ~/.config/tmux/tmux.conf
```

## Verification

Test claude-tmux (in tmux):
```bash
# Press Alt+c in tmux to open the popup
```

Test twig:
```bash
twig --version  # Should show "dev"
twig --help     # Show all commands
```

Test completions:
```bash
twig <TAB>      # Should show command completions
```

Test which-key integration:
```bash
# In tmux: Ctrl+a Space
# Should show "Claude (M-c)" and "+Worktrees" menu items
```

## Files modified

- `home-manager/flake.nix` - Added inputs, overlay with package derivations
- `home-manager/home.nix` - Added packages, tmux keybinding, aliases, completions, skill symlink
- `tmux/config/tmux-which-key.yaml` - Added Claude and Worktrees menus

## Files created

- `claude/skills/update-nix-hash/SKILL.md` - Claude skill for hash updates
- `twig/settings.toml.template` - Reference twig configuration template
- `CLAUDE_TMUX_TWIG_SETUP.md` - This file

## Troubleshooting

If commands are not found:
```bash
# Reload your shell
exec zsh

# Or check if they're in PATH
which claude-tmux twig
```

If tmux keybindings don't work:
```bash
# Reload tmux config
tmux source-file ~/.config/tmux/tmux.conf
```

If you need to update package hashes:
```bash
# Use the skill
/update-nix-hash

# Or manually:
# 1. Run home-manager switch
# 2. Copy the "got:" hash from error
# 3. Update flake.nix
# 4. Run home-manager switch again
```
