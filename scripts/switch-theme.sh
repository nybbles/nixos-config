#!/usr/bin/env bash
# Wallust theme switcher - supports built-in themes and image generation

set -e

show_usage() {
    echo "Usage: switch-theme <theme-name|image-path>"
    echo ""
    echo "Examples:"
    echo "  switch-theme catppuccin-mocha      # Use built-in theme"
    echo "  switch-theme ~/wallpaper.jpg        # Generate from image"
    echo "  switch-theme --list                 # List built-in themes"
    echo ""
    echo "Available built-in themes:"
    wallust theme list 2>/dev/null || echo "  (run 'wallust theme list' to see available themes)"
}

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    wallust theme list
    exit 0
fi

INPUT="$1"

echo "Applying theme: $INPUT"

# Check if it's a file (image) or theme name
if [ -f "$INPUT" ]; then
    # Image file - generate theme
    echo "Generating theme from image..."
    wallust run "$INPUT" -s
else
    # Built-in theme name
    echo "Applying theme..."
    wallust theme "$INPUT" -s
fi

# Reload tmux and update FZF colors in all panes
if command -v tmux &>/dev/null && tmux info &>/dev/null 2>&1; then
    echo "Reloading tmux config..."
    tmux source-file ~/.config/tmux/tmux.conf

    # Update FZF colors in tmux environment so all panes get new colors
    if [ -f ~/.config/fzf/colors.sh ]; then
        echo "Updating FZF colors in tmux..."
        # Source the file and extract the FZF_DEFAULT_OPTS value
        source ~/.config/fzf/colors.sh
        tmux setenv -g FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS"
    fi
fi

# Reload Alacritty via IPC socket
if command -v alacritty &>/dev/null; then
    echo "Reloading Alacritty config..."
    alacritty msg config -r 2>/dev/null || true
fi

echo "✓ Theme applied successfully"
echo ""
echo "Note: K9s config is managed by Nix (skin: wallust is set)"
echo "      Restart K9s to apply the new theme colors"
echo ""
echo "Note: Restart Neovim to apply new theme"
echo "      (Neovim will auto-load theme on next start)"
