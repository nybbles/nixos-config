{
  username,
}: {
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Disable manual generation to work around upstream bug where options.json
  # references store paths without proper context (home-manager#7935)
  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User packages
  home.packages = with pkgs;
    [
      git
      wallust # Wallust theme management
      # Terminal and CLI tools
      alacritty # Terminal emulator with writable config for theme switching
      gh # GitHub CLI
      neofetch # System information tool
      jq # JSON processor
      zoxide # Smart cd command
      fd # Fast find for fzf
      ripgrep # Fast grep for fzf
      bottom # Modern htop alternative (btm)
      moar # Advanced pager with syntax highlighting
      delta # Syntax-highlighting pager for git diffs (themed by wallust)
      eza # Modern ls replacement with colors and icons
      oh-my-zsh

      # Development tools
      pkg-config # Required for building Rust crates with system dependencies
      glib.dev # GLib development headers
      libiconv # Character encoding conversion library

      # Fonts
      nerd-fonts._0xproto # 0xProto Nerd Font for terminal and coding

      # Development tools
      cursor-cli # Cursor CLI for AI-powered development

      tmux
      coreutils-prefixed # GNU coreutils with 'g' prefix (greadlink, etc) for macOS compatibility
      rustup # includes cargo

      # Containerization
      docker
      docker-compose

      duckdb

      tmuxifier
      lazygit # Config managed by wallust for theme switching
      k9s # Kubernetes TUI - config managed by wallust for theme switching

      direnv # Directory-based environment management
      nix-direnv # Nix integration for direnv

      nodejs_22
      unzip

      ffmpeg
      libpq
      pgcli # PostgreSQL client with auto-completion and syntax highlighting
      postgresql # PostgreSQL database and client tools including psql
      xh # Fast and friendly HTTP client (HTTPie in Rust)
      jq

      # Nix formatting
      alejandra # Uncompromising Nix code formatter

      # Cloud CLIs
      # awscli3  # AWS CLI v2
      terraform
      hcp

      # Security
      speedtest-cli # Network speed testing tool

      tree

      # Keyboard customization
      kanata # Key remapping tool

      # Python

      # Claude Code workflow tools
      twig # Git worktree + branch management CLI
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      _1password-gui

      # Media
      spotify

      # Communication and social
      discord
      obsidian

      # Browsers
      google-chrome

      gcc # C compiler needed for Rust builds

      # LSP servers now handled by Mason via nix-ld compatibility

      # GNOME Extensions
      # gnomeExtensions.pop-shell
      # gnomeExtensions.fly-pie
      # gnomeExtensions.just-perfection
      # gnomeExtensions.blur-my-shell
      # gnomeExtensions.gsconnect
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      # macOS-specific packages can go here if needed

      clang
      llvm
      darwin.cctools

      # Python
      pdm

      # Media processing (for audio/video embedding)
      ffmpeg

      # Development tools
      git
      gh

      # AWS CLI for S3/ECR operations
      awscli2

      # Docker for containerization
      docker
      docker-compose

      # Additional tools
      xh
      jq
      pgcli
    ];

  # Configure Git
  programs.git = {
    enable = true;

    # Use delta for diffs (themed by wallust), moar for other paging
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        pager = "delta";
        askPass = "";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      pager = {
        diff = "delta";
        log = "delta";
        show = "delta";
        reflog = "delta";
        blame = "delta";
      };
      # Include wallust-managed delta theme config
      include = {
        path = "~/.config/delta/delta.gitconfig";
      };
      credential = {
        helper = "${pkgs.gh}/bin/gh auth git-credential";
        "https://github.com" = {
          helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
        "https://gist.github.com" = {
          helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
      };
      url = {
        "https://github.com/" = {
          insteadOf = "git@github.com:";
        };
      };
    };
  };

  # Configure wallust theme management
  # Wallust generates configs from templates + color palettes
  # Note: macOS uses ~/Library/Application Support, Linux uses ~/.config
  home.file."${
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/wallust/wallust.toml"
    else ".config/wallust/wallust.toml"
  }".text = ''
    backend = "full"
    color_space = "lab"
    palette = "dark"

    # Template outputs for each application
    [templates]
    alacritty = { template = "alacritty.toml", target = "${
      if pkgs.stdenv.isDarwin
      then "~/Library/Application Support/alacritty/alacritty.toml"
      else "~/.config/alacritty/alacritty.toml"
    }" }
    tmux = { template = "tmux.conf", target = "~/.tmux.conf" }
    k9s = { template = "k9s.yaml", target = "~/.config/k9s/skins/wallust.yaml" }
    lazygit = { template = "lazygit.yml", target = "~/.config/lazygit/config.yml" }
    delta = { template = "delta.gitconfig", target = "~/.config/delta/delta.gitconfig" }
    ohmyposh = { template = "ohmyposh.json", target = "~/.config/oh-my-posh/config.json" }
    nvim = { template = "wallust.lua", target = "~/.config/nvim/colors/wallust.lua" }
  '';

  # Symlink wallust templates from our repo
  # Note: macOS uses ~/Library/Application Support, Linux uses ~/.config
  home.file."${
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/wallust/templates"
    else ".config/wallust/templates"
  }".source = ../wallust/templates;

  # Install switch-theme script
  home.file.".local/bin/switch-theme" = {
    source = ../scripts/switch-theme.sh;
    executable = true;
  };

  # GNOME configuration (Linux only)
  dconf.settings = lib.mkIf pkgs.stdenv.isLinux {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "pop-shell@system76.com"
        "fly-pie@schneegans.github.com"
        "just-perfection-desktop@just-perfection"
        "blur-my-shell@aunetx"
        "gsconnect@andyholmes.github.io"
      ];
    };

    # Pop Shell configuration
    "org/gnome/shell/extensions/pop-shell" = {
      tile-by-default = true;
      active-hint = true;
      smart-gaps = true;
      gap-inner = lib.hm.gvariant.mkUint32 4;
      gap-outer = lib.hm.gvariant.mkUint32 4;
    };

    # Just Perfection configuration
    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      app-menu = false;
      clock-menu-position = 1;
      dash = true;
      hot-corner = false;
      panel = true;
      panel-in-overview = true;
      show-apps-button = true;
      workspace-switcher-should-show = false;
    };

    # Custom keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "alacritty";
      name = "Terminal";
    };

    # Window management shortcuts (Pop Shell style)
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      maximize = ["<Super>m"];
      unmaximize = ["<Super>m"];
      toggle-maximized = ["<Super>m"];
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
    };

    # Interface settings
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
    };
  };

  # Shell configuration - Home Manager will manage basic setup, your dotfiles provide the details
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Let Home Manager manage zsh configuration directly

    shellAliases =
      {
        # Keep original ls aliases for compatibility
        ll = "ls -alF";
        la = "ls -A";

        # Modern eza aliases with icons and colors
        l = "eza --icons --color=always";
        lt = "eza --icons --color=always --tree --level=2";
        lll = "eza --icons --color=always --long --git --header";
        lla = "eza --icons --color=always --long --git --header --all";

        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
        # zoxide provides 'z' and 'zi' commands directly (no aliases needed)
        home-switch = "home-manager switch --flake ~/workbench/nixos-config/home-manager#nimalan";

        # Nix formatting aliases
        nix-format = "alejandra ."; # Format all nix files in current directory
        nix-format-file = "alejandra"; # Format specific file(s) - usage: nix-format-file file.nix
        nix-format-check = "alejandra --check ."; # Check formatting without changing files

        # GitHub PR workflow
        open-current-pr = "~/.config/tmux/scripts/open-current-pr.sh"; # Open current branch's PR in Octo.nvim

        # Development workflow aliases
        git-branch-now = "git checkout -b $(date +%Y-%m-%d-%H%M%S)";
        gbn = "git-branch-now";
        gh-clone-search = "gh repo clone $(gh s --user=twelvelabs-io)";
        ghcs = "gh-clone-search";
        gh-submodule-search = "git submodule add $(gh s --user=twelvelabs-io)";
        gsms = "gh-submodule-search";

        # twig - git worktree manager
        tw = "twig";
        twa = "twig add";
        twl = "twig list";
        twr = "twig remove";

        # Theme management with wallust
        theme = "switch-theme";
        theme-list = "switch-theme --list";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        nix-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos/hosts#framewerk";
      };

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "sudo" "docker" "aws"];
      theme = "robbyrussell";
    };

    initContent = ''
      # Ensure that any packages installed by nix do not clobber the Python path
      unset PYTHONPATH


      # Disable AUTO_CD to prevent automatic directory changes
      unsetopt AUTO_CD

      # Enable vi mode
      bindkey -v

      # Reduce key timeout for faster mode switching
      export KEYTIMEOUT=1

      # Emacs-style keybindings in vi insert mode
      bindkey -M viins '^A' beginning-of-line      # Ctrl+A: beginning of line
      bindkey -M viins '^E' end-of-line            # Ctrl+E: end of line
      bindkey -M viins '^K' kill-line              # Ctrl+K: kill to end of line
      bindkey -M viins '^U' kill-whole-line        # Ctrl+U: kill whole line
      bindkey -M viins '^W' backward-kill-word     # Ctrl+W: kill word backwards
      bindkey -M viins '^Y' yank                   # Ctrl+Y: yank (paste)
      # More intuitive fzf keybindings
      bindkey '^T' fzf-file-widget      # Ctrl+T for files (fzf default)
      bindkey '^G' fzf-cd-widget        # Ctrl+G for directories

      bindkey -M viins '^F' forward-char           # Ctrl+F: forward character
      bindkey -M viins '^B' backward-char          # Ctrl+B: backward character
      bindkey -M viins '^D' delete-char            # Ctrl+D: delete character
      bindkey -M viins '^H' backward-delete-char   # Ctrl+H: backspace
      bindkey -M viins '^P' up-line-or-history     # Ctrl+P: previous history
      bindkey -M viins '^N' down-line-or-history   # Ctrl+N: next history
      # Let fzf handle Ctrl+R for history search
      # The fzf keybinding will be set up automatically by enableZshIntegration
      bindkey -M viins '^S' history-incremental-search-forward   # Ctrl+S: forward search
      # This conflicts with the fzf keybinding to search for files/directories
      # bindkey -M viins '^T' transpose-chars        # Ctrl+T: transpose characters
      bindkey -M viins '^L' clear-screen           # Ctrl+L: clear screen

      # Multi-line command editing (edit in nvim, returns to prompt without executing)
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey -M viins '^X^E' edit-command-line    # Ctrl+X Ctrl+E: edit command in editor

      # Alt-based word movement (emacs-style)
      bindkey -M viins '^[f' forward-word          # Alt+F: forward word
      bindkey -M viins '^[b' backward-word         # Alt+B: backward word
      bindkey -M viins '^[d' kill-word             # Alt+D: kill word forward
      bindkey -M viins '^[^H' backward-kill-word   # Alt+Backspace: kill word backward

      # Keep vi command mode keybindings intact
      bindkey -M vicmd 'k' up-line-or-history
      bindkey -M vicmd 'j' down-line-or-history

      # File insertion widget with fzf
      fzf-file-insert() {
        local selected
        selected=$(fd --type f --hidden --follow --exclude .git . | fzf --height 40% --layout=reverse --border --inline-info --preview 'bat --color=always --style=header,grid --line-range :300 {}' 2>/dev/tty)
        if [[ -n "$selected" ]]; then
          # Quote the file path if it contains spaces
          if [[ "$selected" == *" "* ]]; then
            selected="\"$selected\""
          fi
          LBUFFER="$LBUFFER$selected"
        fi
        zle redisplay
      }
      zle -N fzf-file-insert
      bindkey -M viins '^[f' fzf-file-insert  # Alt+F: insert file path

      # Directory insertion widget with fzf
      fzf-dir-insert() {
        local selected
        selected=$(fd --type d --hidden --follow --exclude .git . | fzf --height 40% --layout=reverse --border --inline-info --preview 'eza --icons --color=always --tree --level=2 {}' 2>/dev/tty)
        if [[ -n "$selected" ]]; then
          # Quote the directory path if it contains spaces
          if [[ "$selected" == *" "* ]]; then
            selected="\"$selected\""
          fi
          LBUFFER="$LBUFFER$selected"
        fi
        zle redisplay
      }
      zle -N fzf-dir-insert
      bindkey -M viins '^[d' fzf-dir-insert   # Alt+D: insert directory path

      # twig completions (git worktree manager)
      if command -v twig &> /dev/null; then
        eval "$(twig completion zsh)"
      fi

      # twt - Create worktree + tmux session in one command
      twt() {
        if [ -z "$1" ]; then
          echo "Usage: twt <branch-name>"
          echo "Creates a worktree with twig and opens it in a new tmux session"
          return 1
        fi

        local branch="$1"

        # Create the worktree
        echo "Creating worktree for: $branch"
        twig add "$branch" || {
          echo "Failed to create worktree"
          return 1
        }

        # Get the repo root and name
        local repo_root=$(git rev-parse --show-toplevel)
        local repo_name=$(basename "$repo_root")

        # Twig creates worktrees in ../<repo-name>-worktree/<branch-sanitized>
        # Sanitize branch name (replace / with -)
        local safe_name=$(echo "$branch" | sed 's|/|-|g')
        local worktree_path="$(dirname "$repo_root")/$repo_name-worktree/$safe_name"

        # Create a session name
        local session_name="$repo_name-$safe_name"

        # Check if session already exists
        if tmux has-session -t "$session_name" 2>/dev/null; then
          echo "Tmux session '$session_name' already exists, switching to it"
          if [ -n "$TMUX" ]; then
            tmux switch-client -t "$session_name"
          else
            tmux attach -t "$session_name"
          fi
          return 0
        fi

        # Create and switch/attach to the session
        echo "Creating tmux session: $session_name in $worktree_path"
        if [ -n "$TMUX" ]; then
          # Inside tmux - create detached and switch to it
          tmux new-session -d -s "$session_name" -c "$worktree_path"
          tmux switch-client -t "$session_name"
        else
          # Outside tmux - create and attach
          tmux new-session -s "$session_name" -c "$worktree_path"
        fi
      }

      # Tmux nuke function - kills server and clears resurrect data
      tmux-nuke() {
        if [ -n "$TMUX" ]; then
          # Running inside tmux - use delayed nuke
          echo "Scheduling tmux nuke in 3 seconds..."
          echo "This tmux session will exit now."
          (sleep 3 && tmux kill-server && rm -rf ~/.tmux/resurrect/* && rm -rf /tmp/tmux-*/default 2>/dev/null && echo "Tmux completely nuked! Start fresh with: tmux") &
          exit
        else
          # Running outside tmux - immediate nuke
          echo "Nuking all tmux sessions and clearing resurrect data..."
          tmux kill-server 2>/dev/null || true
          rm -rf ~/.tmux/resurrect/*
          rm -rf /tmp/tmux-*/default 2>/dev/null || true
          rm -rf /tmp/tmux-$(id -u)/default 2>/dev/null || true
          echo 'Tmux completely nuked! Start fresh with: tmux'
        fi
      }
    '';

    # Note: Moved dotfiles setup to .zshenv (see below) for better reliability
  };

  # Configure oh-my-posh to use external config file
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
  };

  # Configure Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Configure zoxide
  # Uses default 'z' command instead of replacing 'cd', so:
  # - Claude Code and scripts can use regular 'cd'
  # - Interactive shells use 'z' for smart jumping, 'zi' for interactive
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Configure fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  # Configure direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      # Only silence status messages, keep errors visible
      log_status() {
        # Don't print status messages to keep terminal clean
        :
      }
    '';
  };

  # Configure tmux
  programs.tmux = {
    enable = true;
    shell =
      if pkgs.stdenv.isDarwin
      then "/bin/zsh"
      else "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    mouse = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;

    # Plugins now managed by TPM - see ~/workbench/nixos-config/tmux/tpm-plugins.conf
    # To install plugins: Ctrl+a I
    # To update plugins: Ctrl+a U
    # To remove plugins: Remove from tpm-plugins.conf, reload config, then Ctrl+a Alt+u

    extraConfig = ''
      # ========================================================================
      # PATH Configuration
      # ========================================================================
      # Ensure ~/.local/bin comes first for GNU coreutils wrappers
      set-environment -g PATH "$HOME/.local/bin:$PATH"

      # ========================================================================
      # Load Theme (managed by wallust)
      # ========================================================================
      # Wallust writes theme colors to ~/.tmux.conf
      # We source it here so themes work, but all other config is below
      source-file -q ~/.tmux.conf

      # ========================================================================
      # Base Tmux Configuration
      # ========================================================================

      # Set prefix key to Ctrl-a
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Renumber windows when a window is closed
      set -g renumber-windows on

      # Enable focus events for vim
      set -g focus-events on

      # Faster command sequences
      set -s escape-time 10

      # Increase repeat timeout
      set -sg repeat-time 600

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off

      # @wallust integration - theme colors sourced from ~/.tmux.conf above

      # Window navigation
      bind-key -n M-1 select-window -t 1
      bind-key -n M-2 select-window -t 2
      bind-key -n M-3 select-window -t 3
      bind-key -n M-4 select-window -t 4
      bind-key -n M-5 select-window -t 5
      bind-key -n M-6 select-window -t 6
      bind-key -n M-7 select-window -t 7
      bind-key -n M-8 select-window -t 8
      bind-key -n M-9 select-window -t 9

      # Pane navigation (vim-style)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Pane resizing
      bind -r H resize-pane -L 2
      bind -r J resize-pane -D 2
      bind -r K resize-pane -U 2
      bind -r L resize-pane -R 2

      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New window in current path
      bind c new-window -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Copy mode improvements
      bind Enter copy-mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Additional key bindings from dot-config
      bind t choose-tree
      bind -r '<' swap-window -d -t -1
      bind -r '>' swap-window -d -t +1

      # Custom key bindings for scripts
      bind-key M run-shell "${config.home.homeDirectory}/workbench/nixos-config/tmux/scripts/move-window-to-position.sh #{q:target}"

      # Marked pane operations
      bind-key m select-pane -m
      bind-key u select-pane -M
      bind-key s swap-pane
      bind-key P move-pane


      # Enable RGB color
      set -sa terminal-overrides ",*256col*:RGB"

      # Enable undercurl
      set -sa terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -sa terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # Note: DEVELOPER_DIR is unset in shell initContent when TMUX is detected

      # ========================================================================
      # TPM (Tmux Plugin Manager) Setup
      # ========================================================================
      # Plugin declarations (see ~/workbench/nixos-config/tmux/tpm-plugins.conf for details)
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'alexwforsythe/tmux-which-key'
      set -g @plugin 'christoomey/vim-tmux-navigator'
      set -g @plugin 'tmux-plugins/tmux-yank'
      set -g @plugin 'laktak/extrakto'
      set -g @plugin 'wfxr/tmux-fzf-url'
      set -g @plugin 'sainnhe/tmux-fzf'

      # Plugin configuration
      set -g @tmux-which-key-xdg-enable 1
      set -g @tmux-which-key-disable-autoupdate on
      set -g @fzf-url-bind 'u'

      # Bind tmux-fzf to Alt+c for quick access (no prefix needed)
      bind-key -n M-c run-shell -b "$HOME/.config/tmux/plugins/tmux-fzf/main.sh"

      # Bind Alt+s to go directly to session switcher (bypasses both menus)
      bind-key -n M-s run-shell -b "$HOME/.config/tmux/plugins/tmux-fzf/scripts/session.sh switch"

      # Initialize TPM (MUST be at the very end of tmux configuration)
      # TPM with XDG enabled installs to ~/.config/tmux/plugins/
      run '~/.config/tmux/plugins/tpm/tpm'
    '';
  };

  # Session variables
  home.sessionVariables = {
    # XDG Base Directory Specification
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";

    EDITOR = "nvim";
    BROWSER = "open -a 'Google Chrome'";
    TERMINAL = "alacritty";
    PAGER = "moar";
    TMUXIFIER_LAYOUT_PATH = "${config.home.homeDirectory}/.tmuxifier/layouts";
    PDM_VENV_BACKEND = "venv";
    DIRENV_LOG_FORMAT = "";
    GIT_DISCOVERY_ACROSS_FILESYSTEM = "1";
  };

  # Add uv tools to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Symlink tmux scripts and layouts
  home.file = {
    # Note: oh-my-posh config is now managed by wallust (see wallust/templates/ohmyposh.json)

    # GNU coreutils wrappers for macOS compatibility
    # TPM plugins expect GNU coreutils, but macOS has BSD versions
    ".local/bin/readlink" = {
      text = ''
        #!/usr/bin/env bash
        exec greadlink "$@"
      '';
      executable = true;
    };
    ".local/bin/realpath" = {
      text = ''
        #!/usr/bin/env bash
        exec grealpath "$@"
      '';
      executable = true;
    };

    ".config/tmux/scripts/move-window-to-position.sh" = {
      source = ../tmux/scripts/move-window-to-position.sh;
      executable = true;
    };
    ".config/tmux/scripts/open-current-pr.sh" = {
      source = ../tmux/scripts/open-current-pr.sh;
      executable = true;
    };
    # tmux-which-key config (TPM with XDG enabled looks here)
    ".config/tmux/plugins/tmux-which-key/config.yaml".source = ../tmux/config/tmux-which-key.yaml;
    ".tmuxifier/layouts/code.window.sh" = {
      source = ../tmux/layouts/code.window.sh;
      executable = true;
    };

    # Claude Code configuration
    ".claude/CLAUDE.md".source = ../claude/CLAUDE.md;
    ".claude/skills/set-window-title/SKILL.md".source = ../claude/skills/set-window-title/SKILL.md;
    ".claude/skills/update-nix-hash/SKILL.md".source = ../claude/skills/update-nix-hash/SKILL.md;

    # Twig (git worktree manager) template
    ".config/twig/settings.toml.template".source = ../twig/settings.toml.template;
  };

  # Create systemd user service for Kanata (Linux only)
  systemd.user.services.kanata = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Kanata key remapper";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg %h/.config/kanata.kbd";
      Restart = "always";
      RestartSec = 1;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # Enable systemd services (Linux only)
  systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux true;

  # macOS Launch Agent for Alacritty shortcut
  # Note: Use profile path instead of store path to avoid builtins.toFile warning
  launchd.agents.alacritty = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      Label = "com.alacritty.shortcut";
      ProgramArguments = ["${config.home.homeDirectory}/.nix-profile/bin/alacritty"];
      RunAtLoad = false;
      KeepAlive = false;
    };
  };

  # Create proper macOS application entry
  home.activation.createAlacrittyAppEntry = lib.mkIf pkgs.stdenv.isDarwin (lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Creating Alacritty application entry..."

        # Create Applications directory if it doesn't exist
        $DRY_RUN_CMD mkdir -p "$HOME/Applications"

        # Create a proper macOS application bundle using the Nix-managed binary directly
        ALACRITTY_APP="$HOME/Applications/Alacritty.app"
        $DRY_RUN_CMD rm -rf "$ALACRITTY_APP" 2>/dev/null || true

        # Create the app bundle structure
        $DRY_RUN_CMD mkdir -p "$ALACRITTY_APP/Contents/MacOS"
        $DRY_RUN_CMD mkdir -p "$ALACRITTY_APP/Contents/Resources"

        # Copy the actual Alacritty binary (this should preserve architecture info)
        $DRY_RUN_CMD cp "${pkgs.alacritty}/bin/alacritty" "$ALACRITTY_APP/Contents/MacOS/"

        # Create a minimal Info.plist
        $DRY_RUN_CMD cat > "$ALACRITTY_APP/Contents/Info.plist" << 'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>CFBundleExecutable</key>
        <string>alacritty</string>
        <key>CFBundleIdentifier</key>
        <string>com.alacritty</string>
        <key>CFBundleName</key>
        <string>Alacritty</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>0.15.1</string>
        <key>CFBundleVersion</key>
        <string>1</string>
        <key>CFBundleDisplayName</key>
        <string>Alacritty</string>
        <key>LSMinimumSystemVersion</key>
        <string>11.0</string>
        <key>NSHighResolutionCapable</key>
        <true/>
        <key>NSRequiresAquaSystemAppearance</key>
        <false/>
    </dict>
    </plist>
    EOF

        echo "✓ Created Alacritty application bundle at $ALACRITTY_APP"
        echo "  This should now work without Rosetta since it uses the native ARM64 binary"
  '');

  # Create Alacritty application shortcut using a simpler approach
  home.activation.createAlacrittyApp = lib.mkIf pkgs.stdenv.isDarwin (lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Creating Alacritty application shortcut..."

        # Create Applications directory if it doesn't exist
        $DRY_RUN_CMD mkdir -p "$HOME/Applications"

        # Create a simple shell script that launches Alacritty
        ALACRITTY_SCRIPT="$HOME/Applications/Alacritty.command"
        $DRY_RUN_CMD cat > "$ALACRITTY_SCRIPT" << 'EOF'
    #!/bin/bash
    # Launch Alacritty terminal
    exec "${pkgs.alacritty}/bin/alacritty" "$@"
    EOF

        # Make the script executable
        $DRY_RUN_CMD chmod +x "$ALACRITTY_SCRIPT"

        echo "✓ Created Alacritty command script at $ALACRITTY_SCRIPT"
        echo "  You can double-click this file to launch Alacritty"
  '');

  # Automatically clone Neovim config repository
  home.activation.cloneNeovimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.git}/bin:$PATH"
    REPO_PATH="$HOME/workbench/config-nvim"

    # Check GitHub CLI authentication
    if ! $DRY_RUN_CMD ${pkgs.gh}/bin/gh auth status >/dev/null 2>&1; then
      echo "⚠️  GitHub CLI authentication required for cloning repositories!"
      echo "   Please run: gh auth login"
      echo "   Then retry: home-manager switch"
      exit 0  # Don't fail the whole activation
    fi

    if [ ! -d "$REPO_PATH/.git" ]; then
      echo "Cloning neovim config repository..."
      mkdir -p "$HOME/workbench"
      $DRY_RUN_CMD ${pkgs.gh}/bin/gh repo clone nybbles/config-nvim "$REPO_PATH" || {
        echo "Failed to clone repository. Please check your GitHub access."
        exit 0  # Don't fail the whole activation
      }
    else
      echo "Neovim config repository already exists at $REPO_PATH"
      # Optional: pull latest changes using gh
      cd "$REPO_PATH" && $DRY_RUN_CMD ${pkgs.gh}/bin/gh repo sync || true
    fi
  '';

  # Create writable Alacritty config for theme switching
  home.activation.createAlacrittyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
        ALACRITTY_APP_SUPPORT_DIR="$HOME/Library/Application Support/alacritty"
        ALACRITTY_CONFIG="$ALACRITTY_CONFIG_DIR/alacritty.toml"
        ALACRITTY_APP_SUPPORT_CONFIG="$ALACRITTY_APP_SUPPORT_DIR/alacritty.toml"

        echo "Setting up Alacritty config for theme switching..."

        # Create directories if they don't exist
        $DRY_RUN_CMD mkdir -p "$ALACRITTY_CONFIG_DIR"
        $DRY_RUN_CMD mkdir -p "$ALACRITTY_APP_SUPPORT_DIR"

        # Create basic config file if it doesn't exist (wallust will add colors)
        if [ ! -f "$ALACRITTY_APP_SUPPORT_CONFIG" ]; then
          $DRY_RUN_CMD cat > "$ALACRITTY_APP_SUPPORT_CONFIG" << 'EOF'
    # Alacritty Configuration
    # Basic configuration only - colors managed by wallust

    [general]
    ipc_socket = true
    live_config_reload = true

    [font]
    size = 14.0

    [font.normal]
    family = "0xProto Nerd Font"
    style = "Regular"

    [font.bold]
    family = "0xProto Nerd Font"
    style = "Bold"

    [font.italic]
    family = "0xProto Nerd Font"
    style = "Italic"

    [window]
    decorations = "full"

    [window.padding]
    x = 6
    y = 6

    # Colors will be added here by wallust when themes are applied
    EOF
          echo "✓ Created basic Alacritty config at $ALACRITTY_APP_SUPPORT_CONFIG"
        fi
  '';

  # Symlink Neovim configuration to external repository
  xdg.configFile."nvim" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/workbench/config-nvim";
    recursive = true;
  };
}
