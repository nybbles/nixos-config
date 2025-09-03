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
  home.homeDirectory = "/home/${username}";

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
    # Terminal and CLI tools
    alacritty
    gh # GitHub CLI
    zoxide # Smart cd command
    fd # Fast find for fzf
    ripgrep # Fast grep for fzf
    bottom # Modern htop alternative (btm)
    moar # Advanced pager with syntax highlighting
    oh-my-posh
    oh-my-zsh

    # Communication and social
    discord
    obsidian

    # Security
    _1password-gui

    # Media
    spotify

    # Development tools
    neovim
    tmux
    rustup # includes cargo
    uv # Python package manager
    claude-code # Claude CLI
    pyenv
    tmuxifier
    lazygit

    # GNOME Extensions
    # gnomeExtensions.pop-shell
    # gnomeExtensions.fly-pie
    # gnomeExtensions.just-perfection
    # gnomeExtensions.blur-my-shell
    # gnomeExtensions.gsconnect

    kanata
    nodejs
    unzip

    # Python ecosystem
    python3
    pyenv
    uv
  ];

  # Configure Alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "0xProto Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "0xProto Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "0xProto Nerd Font";
          style = "Italic";
        };
        size = 12.0;
      };

      window = {
        padding = {
          x = 6;
          y = 6;
        };
        decorations = "full";
      };

      colors = {
        # Catppuccin Mocha theme
        primary = {
          background = "0x1e1e2e";
          foreground = "0xcdd6f4";
          dim_foreground = "0x7f849c";
          bright_foreground = "0xcdd6f4";
        };

        cursor = {
          text = "0x1e1e2e";
          cursor = "0xf5e0dc";
        };

        vi_mode_cursor = {
          text = "0x1e1e2e";
          cursor = "0xb4befe";
        };

        search = {
          matches = {
            foreground = "0x1e1e2e";
            background = "0xa6adc8";
          };
          focused_match = {
            foreground = "0x1e1e2e";
            background = "0xa6e3a1";
          };
        };

        footer_bar = {
          foreground = "0x1e1e2e";
          background = "0xa6adc8";
        };

        hints = {
          start = {
            foreground = "0x1e1e2e";
            background = "0xf9e2af";
          };
          end = {
            foreground = "0x1e1e2e";
            background = "0xa6adc8";
          };
        };

        selection = {
          text = "0x1e1e2e";
          background = "0xf5e0dc";
        };

        normal = {
          black = "0x45475a";
          red = "0xf38ba8";
          green = "0xa6e3a1";
          yellow = "0xf9e2af";
          blue = "0x89b4fa";
          magenta = "0xf5c2e7";
          cyan = "0x94e2d5";
          white = "0xbac2de";
        };

        bright = {
          black = "0x585b70";
          red = "0xf38ba8";
          green = "0xa6e3a1";
          yellow = "0xf9e2af";
          blue = "0x89b4fa";
          magenta = "0xf5c2e7";
          cyan = "0x94e2d5";
          white = "0xa6adc8";
        };

        dim = {
          black = "0x45475a";
          red = "0xf38ba8";
          green = "0xa6e3a1";
          yellow = "0xf9e2af";
          blue = "0x89b4fa";
          magenta = "0xf5c2e7";
          cyan = "0x94e2d5";
          white = "0xbac2de";
        };

        indexed_colors = [
          { index = 16; color = "0xfab387"; }
          { index = 17; color = "0xf5e0dc"; }
        ];
      };
    };
  };

  # Configure Git
  programs.git = {
    enable = true;

    # Use moar as pager for git commands
    extraConfig = {
      core.pager = "moar";
      pager = {
        diff = "moar";
        log = "moar";
        show = "moar";
      };
    };
  };

  # GNOME configuration
  dconf.settings = {
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
      nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nixos-config/nixos#framewerk";
      home-switch = "home-manager switch --flake ~/code/nixos-config/home-manager#nimalan";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "z" ];
      theme = "robbyrussell";
    };

    # Add keybindings for history navigation with ctrl+p and ctrl+n
    initExtra = ''
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
      
      # Navigation and utilities
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.fzf-tmux-url
      tmuxPlugins.yank
      
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
    ".tmuxifier/layouts/code.window.sh" = {
      source = ../tmux/layouts/code.window.sh;
      executable = true;
    };
    
    # Kanata keyboard configuration
    ".config/kanata.kbd".source = ../kanata.kbd;
  };

  
  # Create systemd user service for Kanata
  systemd.user.services.kanata = {
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

  # Enable the service
  systemd.user.startServices = true;

}
