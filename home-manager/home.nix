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
        primary = {
          background = "0x1e1e1e";
          foreground = "0xd4d4d4";
        };
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
      theme = "robbyrussel";
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

  # Configure oh-my-posh with night-owl theme and vi mode indicator
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
      version = 3;
      final_space = true;
      console_title_template = "{{ .Folder }}";
      transient_prompt = {
        template = "❯ ";
        foreground = "#d6deeb";
        background = "transparent";
      };
      blocks = [
        {
          type = "prompt";
          alignment = "left";
          segments = [
            # Vi mode indicator
            {
              type = "vi";
              style = "diamond";
              leading_diamond = "╭─\ue0b6";
              trailing_diamond = "\ue0b0";
              template = " {{ .String }} ";
              foreground = "#011627";
              background = "#22da6e";
              background_templates = [
                "{{ if eq .String \"NORMAL\" }}#f4e56d{{ end }}"
              ];
              properties = {
                vi_insert_prompt = "INSERT";
                vi_cmd_prompt = "NORMAL";
              };
            }
            # Hostname
            {
              type = "session";
              style = "diamond";
              template = " {{ .HostName }} ";
              foreground = "#011627";
              background = "#21c7a8";
              trailing_diamond = "\ue0b0";
            }
            # Root user indicator
            {
              type = "root";
              style = "powerline";
              powerline_symbol = "\ue0b0";
              template = " \uf292 ";
              foreground = "#ffeb95";
              background = "#ef5350";
            }
            # Current directory
            {
              type = "path";
              style = "powerline";
              powerline_symbol = "\ue0b0";
              template = "{{ path .Path .Location }}";
              foreground = "#011627";
              background = "#82AAFF";
              properties = {
                folder_icon = "\uf07c ";
                folder_separator_icon = "<#011627>\ue0b1</> ";
                home_icon = " \ueb06 ";
                style = "agnoster";
              };
            }
            # Git status
            {
              type = "git";
              style = "powerline";
              powerline_symbol = "\ue0b0";
              template = " {{ url .UpstreamIcon .UpstreamURL }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} \ueb4b {{ .StashCount }}{{ end }} ";
              foreground = "#011627";
              background = "#addb67";
              background_templates = [
                "{{ if or (.Working.Changed) (.Staging.Changed) }}#e4cf6a{{ end }}"
                "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#f78c6c{{ end }}"
                "{{ if gt .Ahead 0 }}#C792EA{{ end }}"
                "{{ if gt .Behind 0 }}#c792ea{{ end }}"
              ];
              properties = {
                branch_icon = "\ue725 ";
                fetch_stash_count = true;
                fetch_status = true;
                fetch_upstream_icon = true;
                fetch_worktree_count = true;
              };
            }
            # Execution time
            {
              type = "executiontime";
              style = "diamond";
              leading_diamond = "<transparent,#575656>\ue0b0</>";
              trailing_diamond = "\ue0b4";
              template = " {{ .FormattedMs }}";
              foreground = "#d6deeb";
              background = "#575656";
              properties = {
                style = "roundrock";
                threshold = 0;
              };
            }
          ];
        }
        # Right side prompt with language versions
        {
          type = "prompt";
          alignment = "right";
          overflow = "break";
          segments = [
            # Python
            {
              type = "python";
              style = "diamond";
              leading_diamond = "\ue0b2";
              trailing_diamond = "<transparent,#306998>\ue0b2</>";
              template = "\ue235  {{ if .Error }}{{ .Error }}{{ else }}{{ if .Venv }}{{ .Venv }} {{ end }}{{ .Full }}{{ end }}";
              foreground = "#FFE873";
              background = "#306998";
            }
            # Node.js
            {
              type = "node";
              style = "diamond";
              leading_diamond = "\ue0b2";
              trailing_diamond = "<transparent,#303030>\ue0b2</>";
              template = "\ue718 {{ if .PackageManagerIcon }}{{ .PackageManagerIcon }} {{ end }}{{ .Full }} ";
              foreground = "#3C873A";
              background = "#303030";
              properties = {
                fetch_package_manager = true;
                npm_icon = "<#cc3a3a>\ue71e</> ";
                yarn_icon = "<#348cba>\ue6a7</> ";
              };
            }
            # Rust
            {
              type = "rust";
              style = "diamond";
              leading_diamond = "\ue0b2";
              trailing_diamond = "<transparent,#ffffff>\ue0b2</>";
              template = "\ue7a8 {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              foreground = "#000000";
              background = "#ffffff";
            }
            # Time
            {
              type = "time";
              style = "diamond";
              leading_diamond = "\ue0b2";
              trailing_diamond = "\ue0b4";
              template = "\ue641 {{ .CurrentDate | date .Format }}";
              foreground = "#d6deeb";
              background = "#234d70";
              properties = {
                time_format = "15:04:05";
              };
            }
          ];
        }
        # New line with prompt symbol
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "text";
              style = "plain";
              template = "╰─";
              foreground = "#21c7a8";
            }
            {
              type = "status";
              style = "plain";
              template = "❯❯";
              foreground = "#22da6e";
              foreground_templates = [
                "{{ if gt .Code 0 }}#ef5350{{ end }}"
              ];
              properties = {
                always_enabled = true;
              };
            }
          ];
        }
      ];
    };
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

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    PAGER = "moar";
    # Point tmux to your dotfiles config
    TMUX_CONF = "${config.home.homeDirectory}/.config/tmux/tmux.conf";
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
