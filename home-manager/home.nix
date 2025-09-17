{ username }:
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User packages
  home.packages = with pkgs; [
    git
    # Terminal and CLI tools
    alacritty  # Terminal emulator with writable config for theme switching
    gh # GitHub CLI
    neofetch # System information tool
    jq # JSON processor
    zoxide # Smart cd command
    fd # Fast find for fzf
    ripgrep # Fast grep for fzf
    bottom # Modern htop alternative (btm)
    moar # Advanced pager with syntax highlighting
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
    rustup # includes cargo
    
    # Containerization
    docker
    docker-compose

    pyenv
    tmuxifier
    lazygit

    claude-code # Claude CLI

    nodejs
    unzip

    # Python ecosystem
    pyenv
    uv

    pdm
    # Install virtualenv for Python 3.13 separately
    python313.pkgs.virtualenv

    ffmpeg
    libpq

    lazysql

    # Security
  ] ++ lib.optionals pkgs.stdenv.isLinux [
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

    kanata
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific packages can go here if needed

    clang
    llvm
    darwin.cctools


  ];


  # Configure Git
  programs.git = {
    enable = true;

    # Use moar as pager for git commands
    extraConfig = {
      core = {
        pager = "moar";
        askPass = "";
      };
      pager = {
        diff = "moar";
        log = "moar";
        show = "moar";
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
      close = [ "<Super>q" ];
      maximize = [ "<Super>m" ];
      unmaximize = [ "<Super>m" ];
      toggle-maximized = [ "<Super>m" ];
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
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

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      cd = "z"; # Use zoxide instead of cd
      home-switch = "home-manager switch --flake ~/.config/home-manager#nimalan";
      themester = "~/code/themester/target/release/themester"; # Themester theme manager
      themester-daemon = "~/code/themester/target/release/themester-daemon"; # Themester daemon
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      nix-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos/hosts#framewerk";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "z" ];
      theme = "robbyrussell";
    };

    # Add keybindings for history navigation with ctrl+p and ctrl+n
    initContent = ''
      # Enable vi mode
      bindkey -v
      
      # Enable ctrl+p and ctrl+n for history navigation in vi mode
      bindkey '^P' up-line-or-history
      bindkey '^N' down-line-or-history
      
      # Reduce key timeout for faster mode switching
      export KEYTIMEOUT=1
    '';

    # Note: Moved dotfiles setup to .zshenv (see below) for better reliability
  };

  # Configure oh-my-posh to use external config file
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
  };

  # Create oh-my-posh config file with proper Unicode via Home Manager file management
  home.file.".config/oh-my-posh/config.json".text = ''
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 3,
  "final_space": true,
  "console_title_template": "{{ .Folder }}",
  "transient_prompt": {
    "template": "❯ ",
    "foreground": "#a6e3a1",
    "background": "transparent"
  },
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "text",
          "style": "plain",
          "template": "╭─",
          "foreground": "#89b4fa"
        },
        {
          "type": "vi",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "template": " {{ .String }} ",
          "foreground": "#1e1e2e",
          "background": "#a6e3a1",
          "background_templates": [
            "{{ if eq .String \"NORMAL\" }}#f9e2af{{ end }}"
          ],
          "properties": {
            "vi_insert_prompt": "INSERT",
            "vi_cmd_prompt": "NORMAL"
          }
        },
        {
          "type": "text",
          "style": "plain",
          "template": "   ",
          "foreground": "transparent"
        },
        {
          "type": "session",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "template": " {{ .HostName }} ",
          "foreground": "#cdd6f4",
          "background": "#89b4fa"
        },
        {
          "type": "text",
          "style": "plain",
          "template": "   ",
          "foreground": "transparent"
        },
        {
          "type": "path",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "template": " 📁 {{ path .Path .Location }} ",
          "foreground": "#1e1e2e",
          "background": "#fab387",
          "properties": {
            "style": "agnoster",
            "max_depth": 3,
            "folder_separator_icon": "/"
          }
        },
        {
          "type": "text",
          "style": "plain",
          "template": "   ",
          "foreground": "transparent"
        },
        {
          "type": "git",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "template": " 🌿 {{ .HEAD }}{{ if .Working.Changed }} ⚡{{ .Working.String }}{{ end }}{{ if .Staging.Changed }} ➕{{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} 📦{{ .StashCount }}{{ end }} ",
          "foreground": "#1e1e2e",
          "background": "#94e2d5",
          "background_templates": [
            "{{ if or (.Working.Changed) (.Staging.Changed) }}#f9e2af{{ end }}",
            "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#f38ba8{{ end }}",
            "{{ if gt .Ahead 0 }}#cba6f7{{ end }}",
            "{{ if gt .Behind 0 }}#cba6f7{{ end }}"
          ],
          "properties": {
            "fetch_stash_count": true,
            "fetch_status": true,
            "fetch_upstream_icon": true
          }
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "right",
      "overflow": "break",
      "segments": [
        {
          "type": "python",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "template": " 🐍 {{ if .Venv }}({{ .Venv }}) {{ end }}{{ .Major }}.{{ .Minor }} ",
          "foreground": "#1e1e2e",
          "background": "#f9e2af"
        },
        {
          "type": "text",
          "style": "plain",
          "template": "   ",
          "foreground": "transparent"
        },
        {
          "type": "node",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "template": " ⬢ {{ .Major }}.{{ .Minor }} ",
          "foreground": "#1e1e2e",
          "background": "#a6e3a1"
        },
        {
          "type": "text",
          "style": "plain",
          "template": "   ",
          "foreground": "transparent"
        },
        {
          "type": "time",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "template": " 🕐 {{ .CurrentDate | date .Format }} ",
          "foreground": "#cdd6f4",
          "background": "#89b4fa",
          "properties": {
            "time_format": "15:04"
          }
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "text",
          "style": "plain",
          "template": "╰─",
          "foreground": "#89b4fa"
        },
        {
          "type": "status",
          "style": "plain",
          "template": "❯ ",
          "foreground": "#a6e3a1",
          "foreground_templates": [
            "{{ if gt .Code 0 }}#f38ba8{{ end }}"
          ],
          "properties": {
            "always_enabled": true
          }
        }
      ]
    }
  ]
}
  '';

  # Configure Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Configure zoxide
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

  # Configure tmux
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    mouse = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    
    plugins = with pkgs; [
      # Theme - must be first to avoid status bar conflicts
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_left_separator ""
          set -g @catppuccin_window_right_separator " "
          set -g @catppuccin_window_middle_separator " █"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_default_fill "number"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_status_modules_right "directory user host session"
          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator ""
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_directory_text "#{pane_current_path}"
        '';
      }
      
      # Which-key for tmux - shows available key bindings
      {
        plugin = tmuxPlugins.tmux-which-key;
        extraConfig = ''
          set -g @tmux-which-key-xdg-open 'firefox'
          set -g @tmux-which-key-disable-autoupdate 'on'
          set -g @tmux-which-key-disable-autobuild 'on'
          
          # Set custom keybinding for tmux-which-key (leader + space)
          set -g @tmux-which-key-key-binding Space
          
          # Key descriptions for which-key
          set -g @tmux-which-key-key-descriptions '
            "h": "Select left pane",
            "j": "Select down pane", 
            "k": "Select up pane",
            "l": "Select right pane",
            "H": "Resize pane left",
            "J": "Resize pane down",
            "K": "Resize pane up", 
            "L": "Resize pane right",
            "|": "Split window horizontally",
            "-": "Split window vertically",
            "c": "Create new window",
            "r": "Reload tmux config",
            "t": "Choose tree (sessions/windows)",
            "w": "Fuzzy window selector",
            "f": "Fuzzy session/path selector",
            "M": "Move window to position",
            "<": "Swap window left",
            ">": "Swap window right",
            "Enter": "Enter copy mode",
            "Space": "Show this help menu"
          '
          
          # Manually source the init file since autobuild is disabled
          run-shell "tmux source-file ${pkgs.tmuxPlugins.tmux-which-key}/share/tmux-plugins/tmux-which-key/plugin/init.example.tmux"
          
          # Override the sessions menu to fix the rename command
          set -g @wk_menu_sessions \
          'Choose "s" "choose-tree -Zs" \
          New "N" "new-session" \
          Rename "r" "command-prompt -I \"#S\" \"rename-session \\\"%%\\\"\""'
        '';
      }
      
      # Navigation and utilities
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.fzf-tmux-url
      tmuxPlugins.yank
      
      # Enhanced fuzzy finding
      {
        plugin = tmuxPlugins.tmux-fzf;
        extraConfig = ''
          # tmux-fzf configuration
          set -g @fzf-url-bind 'u'
        '';
      }
      
      # Session persistence - must be after theme
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-restore-bash-history 'on'
        '';
      }
      
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
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
      bind w run-shell "${config.home.homeDirectory}/code/nixos-config/tmux/scripts/fzf-window.sh"
      bind -r '<' swap-window -d -t -1
      bind -r '>' swap-window -d -t +1
      
      # Custom key bindings for scripts
      bind-key f run-shell "${config.home.homeDirectory}/code/nixos-config/tmux/scripts/fzf-session-path.sh"
      bind-key M run-shell "${config.home.homeDirectory}/code/nixos-config/tmux/scripts/move-window-to-position.sh #{q:target}"
      
      # Enable RGB color
      set -sa terminal-overrides ",*256col*:RGB"
      
      # Enable undercurl
      set -sa terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -sa terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    PAGER = "moar";
    TMUXIFIER_LAYOUT_PATH = "${config.home.homeDirectory}/.tmuxifier/layouts";
  };

  # Symlink tmux scripts and layouts
  home.file = {
    ".config/tmux/scripts/fzf-session-path.sh" = {
      source = ../tmux/scripts/fzf-session-path.sh;
      executable = true;
    };
    ".config/tmux/scripts/move-window-to-position.sh" = {
      source = ../tmux/scripts/move-window-to-position.sh;
      executable = true;
    };
    ".config/tmux/scripts/fzf-window.sh" = {
      source = ../tmux/scripts/fzf-window.sh;
      executable = true;
    };
    ".tmuxifier/layouts/code.window.sh" = {
      source = ../tmux/layouts/code.window.sh;
      executable = true;
    };
    
    # Kanata keyboard configuration
    ".config/kanata.kbd".source = ../kanata.kbd;
  };

  
  # Create systemd user service for Kanata (Linux only)
  systemd.user.services.kanata = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Kanata key remapper";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg %h/.config/kanata.kbd";
      Restart = "always";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Enable the service (Linux only)
  systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux true;

  # macOS Launch Agent for Alacritty shortcut
  launchd.agents.alacritty = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      Label = "com.alacritty.shortcut";
      ProgramArguments = [ "${pkgs.alacritty}/bin/alacritty" ];
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
    REPO_PATH="$HOME/code/config-nvim"
    
    # Check GitHub CLI authentication
    if ! $DRY_RUN_CMD ${pkgs.gh}/bin/gh auth status >/dev/null 2>&1; then
      echo "⚠️  GitHub CLI authentication required for cloning repositories!"
      echo "   Please run: gh auth login"
      echo "   Then retry: home-manager switch"
      exit 0  # Don't fail the whole activation
    fi
    
    if [ ! -d "$REPO_PATH/.git" ]; then
      echo "Cloning neovim config repository..."
      mkdir -p "$HOME/code"
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

  # Automatically clone Themester repository
  home.activation.cloneThemester = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.git}/bin:$PATH"
    REPO_PATH="$HOME/code/themester"
    
    # Check GitHub CLI authentication
    if ! $DRY_RUN_CMD ${pkgs.gh}/bin/gh auth status >/dev/null 2>&1; then
      echo "⚠️  GitHub CLI authentication required for cloning repositories!"
      echo "   Please run: gh auth login"
      echo "   Then retry: home-manager switch"
      exit 0  # Don't fail the whole activation
    fi
    
    if [ ! -d "$REPO_PATH/.git" ]; then
      echo "Cloning themester repository..."
      mkdir -p "$HOME/code"
      $DRY_RUN_CMD ${pkgs.gh}/bin/gh repo clone nybbles/themester "$REPO_PATH" || {
        echo "Failed to clone themester repository. Please check your GitHub access to private repositories."
        exit 0  # Don't fail the whole activation
      }
    else
      echo "Themester repository already exists at $REPO_PATH"
      # Optional: pull latest changes using gh
      cd "$REPO_PATH" && $DRY_RUN_CMD ${pkgs.gh}/bin/gh repo sync || true
    fi

    export PATH="${pkgs.git}/bin:${pkgs.rustc}/bin:${pkgs.cargo}/bin:${pkgs.clang}/bin:${pkgs.pkg-config}/bin:$PATH"
    export CC="${pkgs.clang}/bin/clang"
    export CXX="${pkgs.clang}/bin/clang++"
    export PKG_CONFIG_PATH="${pkgs.pkg-config}/lib/pkgconfig:${pkgs.glib.dev}/lib/pkgconfig"
    export LDFLAGS="-L${pkgs.libiconv}/lib"
    export CPPFLAGS="-I${pkgs.libiconv}/include"
    export RUSTFLAGS="-L native=${pkgs.libiconv}/lib"
    
    # Set up Rust toolchain if needed
    if ! $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup show 2>/dev/null | grep -q "default toolchain"; then
      echo "Setting up Rust toolchain..."
      $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup default stable || {
        echo "Failed to set up Rust toolchain. Please run manually: rustup default stable"
      }
    fi
    
    # Build themester with cargo if not already built
    if [ -d "$REPO_PATH" ] && [ -f "$REPO_PATH/Cargo.toml" ] && [ ! -f "$REPO_PATH/target/release/themester" ]; then
      echo "Building themester with cargo..."
      cd "$REPO_PATH" && $DRY_RUN_CMD ${pkgs.cargo}/bin/cargo build --release || {
        echo "Failed to build themester. You may need to run: rustup default stable"
      }
    fi
  '';

  # Install Themester themes
  home.activation.installThemesterThemes = lib.hm.dag.entryAfter ["cloneThemester"] ''
    if [ -d "$HOME/code/themester/themes" ]; then
      echo "Installing Themester themes..."
      mkdir -p "$HOME/.themes/available"
      $DRY_RUN_CMD cp -r "$HOME/code/themester/themes"/* "$HOME/.themes/available/" || {
        echo "Failed to install themes. Please check permissions."
      }
    else
      echo "Themester themes directory not found, skipping theme installation"
    fi
  '';

  # Setup Themester daemon service (Linux and macOS)
  home.activation.setupThemesterDaemon = lib.hm.dag.entryAfter ["installThemesterThemes"] ''
    if [ -f "$HOME/code/themester/target/release/themester-daemon" ]; then
      echo "Setting up Themester daemon..."
      
      if [[ "$(uname)" == "Linux" ]]; then
        # Linux: Install systemd service
        $DRY_RUN_CMD "$HOME/code/themester/target/release/themester" install all || {
          echo "Failed to install Themester service. Please run manually: themester install all"
        }
        
        # Reload systemd and enable service
        if command -v systemctl >/dev/null 2>&1; then
          $DRY_RUN_CMD systemctl --user daemon-reload || true
          $DRY_RUN_CMD systemctl --user enable themester-daemon.service || {
            echo "Failed to enable Themester daemon. Please run manually: systemctl --user enable themester-daemon.service"
          }
        fi
      elif [[ "$(uname)" == "Darwin" ]]; then
        # macOS: Setup Launch Agent
        echo "Setting up Themester daemon for macOS..."
        
        # Create LaunchAgents directory if it doesn't exist
        LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
        $DRY_RUN_CMD mkdir -p "$LAUNCH_AGENTS_DIR"
        
        # Create Launch Agent plist file
        PLIST_FILE="$LAUNCH_AGENTS_DIR/com.themester.daemon.plist"
        $DRY_RUN_CMD cat > "$PLIST_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.themester.daemon</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>THEMESTER_DAEMON_PATH</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <true/>
    
    <key>StandardOutPath</key>
    <string>THEMESTER_LOG_PATH</string>
    
    <key>StandardErrorPath</key>
    <string>THEMESTER_LOG_PATH</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>RUST_LOG</key>
        <string>info</string>
        <key>HOME</key>
        <string>THEMESTER_HOME_PATH</string>
        <key>USER</key>
        <string>THEMESTER_USER</string>
    </dict>
    
    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
EOF
        
        # Replace placeholders in plist file
        DAEMON_PATH="$HOME/code/themester/target/release/themester-daemon"
        LOG_PATH="$HOME/.local/share/themester/themester-daemon.log"
        HOME_PATH="$HOME"
        USER_NAME="$(whoami)"
        
        # Create log directory
        $DRY_RUN_CMD mkdir -p "$(dirname "$LOG_PATH")"
        
        # Replace placeholders
        $DRY_RUN_CMD sed -i.bak "s|THEMESTER_DAEMON_PATH|$DAEMON_PATH|g" "$PLIST_FILE"
        $DRY_RUN_CMD sed -i.bak "s|THEMESTER_LOG_PATH|$LOG_PATH|g" "$PLIST_FILE"
        $DRY_RUN_CMD sed -i.bak "s|THEMESTER_HOME_PATH|$HOME_PATH|g" "$PLIST_FILE"
        $DRY_RUN_CMD sed -i.bak "s|THEMESTER_USER|$USER_NAME|g" "$PLIST_FILE"
        $DRY_RUN_CMD rm -f "$PLIST_FILE.bak"
        
        echo "✓ Created Launch Agent: $PLIST_FILE"
        
        # Unload existing service if running
        if launchctl list | grep -q "com.themester.daemon"; then
          echo "Unloading existing themester daemon..."
          $DRY_RUN_CMD launchctl unload "$PLIST_FILE" 2>/dev/null || true
        fi
        
        # Load and start the service
        echo "Loading themester daemon..."
        $DRY_RUN_CMD launchctl load "$PLIST_FILE" || {
          echo "Failed to load themester daemon. Please run manually: launchctl load $PLIST_FILE"
        }
        
        echo "✓ Themester daemon setup complete for macOS"
        echo "  Log file: $LOG_PATH"
        echo "  To check status: launchctl list | grep themester"
        echo "  To stop: launchctl unload $PLIST_FILE"
        echo "  To start: launchctl load $PLIST_FILE"
      else
        echo "Unsupported operating system: $(uname)"
      fi
    else
      echo "Themester daemon binary not found, skipping daemon setup"
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
    
    # Check if Application Support config exists and has theme data
    if [ -f "$ALACRITTY_APP_SUPPORT_CONFIG" ] && grep -q "themester_managed" "$ALACRITTY_APP_SUPPORT_CONFIG" 2>/dev/null; then
      echo "Found existing themed config in Application Support"
      # Copy it to .config if .config doesn't have theme data
      if [ ! -f "$ALACRITTY_CONFIG" ] || ! grep -q "themester_managed" "$ALACRITTY_CONFIG" 2>/dev/null; then
        $DRY_RUN_CMD cp "$ALACRITTY_APP_SUPPORT_CONFIG" "$ALACRITTY_CONFIG"
        echo "✓ Copied themed config to $ALACRITTY_CONFIG"
      fi
    else
      # Create basic config file if it doesn't exist
      if [ ! -f "$ALACRITTY_CONFIG" ]; then
        $DRY_RUN_CMD cat > "$ALACRITTY_CONFIG" << 'EOF'
# Alacritty Configuration
# Basic configuration only - colors managed by Themester

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

# Colors will be added here by Themester when themes are applied
EOF
        echo "✓ Created basic Alacritty config at $ALACRITTY_CONFIG"
      fi
      
      # Copy to Application Support if it doesn't exist there
      if [ ! -f "$ALACRITTY_APP_SUPPORT_CONFIG" ]; then
        $DRY_RUN_CMD cp "$ALACRITTY_CONFIG" "$ALACRITTY_APP_SUPPORT_CONFIG"
        echo "✓ Copied config to Application Support"
      fi
    fi
    
    # Create symlink from .config to Application Support to keep them in sync
    # This way themester can update Application Support and .config will reflect changes
    if [ ! -L "$ALACRITTY_CONFIG" ]; then
      $DRY_RUN_CMD rm -f "$ALACRITTY_CONFIG"
      $DRY_RUN_CMD ln -sf "$ALACRITTY_APP_SUPPORT_CONFIG" "$ALACRITTY_CONFIG"
      echo "✓ Created symlink from .config to Application Support"
    fi
  '';

  # Symlink Neovim configuration to external repository
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/code/config-nvim";
    recursive = true;
  };

}
