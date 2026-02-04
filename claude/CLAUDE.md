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

## Package Management Strategy

This system uses multiple package managers strategically, each for its strengths.

### Use Nix for:

- **System-level tools and CLI programs** that need to be in PATH
  - Examples: `git`, `gh`, `tmux`, `neovim`, `ripgrep`, `fd`, `jq`
  - Benefit: Reproducible versions, system-wide availability

- **Applications and development tools**
  - Examples: `alacritty`, `docker`, `terraform`, `nodejs`
  - Benefit: Declarative configuration, easy to replicate across machines

- **Custom packages you build** (using overlays)
  - Examples: `claude-tmux`, `twig` (in flake.nix overlay)
  - Benefit: Pin specific versions or patches, integrated with home-manager

### Use specialized package managers for:

- **Tmux plugins** → **TPM (Tmux Plugin Manager)**
  - Location: `~/workbench/nixos-config/tmux/tpm-plugins.conf`
  - Why: Latest versions from GitHub, standard tool for tmux ecosystem
  - Install: `Ctrl+a I` | Update: `Ctrl+a U`

- **Neovim plugins** → **lazy.nvim** (or your plugin manager of choice)
  - Location: Managed in neovim config
  - Why: Designed for neovim, handles lazy loading, version pinning

- **VSCode/Cursor extensions** → **Built-in extension manager**
  - Why: Native integration, automatic updates

- **Language-specific tools** → **Use language's package manager**
  - Rust: `cargo install`
  - Node: `npm install -g` or `npx`
  - Python: `pipx` or `uv tool install`
  - Go: `go install`
  - Why: Latest versions, ecosystem integration

### When to choose which:

**Choose Nix when:**
- You want reproducibility across machines
- The tool needs to be available system-wide
- You need a specific version pinned
- It's a core system tool

**Choose specialized manager when:**
- It's an extension/plugin for a specific tool
- You want the absolute latest version
- The ecosystem's package manager is better maintained
- Quick updates matter more than reproducibility

### Example: Why we moved tmux plugins from Nix to TPM

**Problem with Nix approach:**
- Nix packages can be outdated (e.g., old tmux-which-key without YAML support)
- Required rebuilding home-manager for plugin updates
- Hardcoded paths broke functionality
- Fighting the tool instead of using it

**Benefits of TPM approach:**
- Latest versions directly from GitHub repos
- Update individual plugins without rebuilding system
- Standard tool that tmux community uses
- Plugin authors test against TPM, not Nix

**Best practice:** Use Nix for the foundation (tmux itself), use TPM for the extensions (plugins).
