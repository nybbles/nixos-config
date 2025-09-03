# Home Manager Configuration

This is a standalone Home Manager configuration, separate from the NixOS system configuration.

## Usage

### Initial Setup

First time setup:
```bash
# Install home-manager if not already installed
nix-shell -p home-manager

# Switch to the configuration
home-manager switch --flake .#nimalan
```

### Updating Configuration

After making changes to `home.nix`:
```bash
home-manager switch --flake .#nimalan
```

### Benefits

- Update user configuration without sudo
- Faster iteration on user settings
- Independent from system rebuilds
- Can be version controlled separately if desired

### System Configuration

The NixOS system configuration remains at the root and is updated with:
```bash
sudo nixos-rebuild switch --flake ..#framewerk
```