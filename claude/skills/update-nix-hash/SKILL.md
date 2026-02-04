# update-nix-hash

Update Nix dependency hashes when builds fail due to hash mismatches.

## Usage

Invoke with `/update-nix-hash` when:
- `home-manager switch` fails with a hash mismatch error
- You've updated a flake input and need to refresh dependency hashes

## What this skill does

1. Run `home-manager switch` to detect hash mismatches
2. Parse the error output for the correct hash
3. Update the flake.nix with the new hash
4. Re-run `home-manager switch` to verify

## Example error pattern

```
error: hash mismatch in fixed-output derivation '/nix/store/...':
  specified: sha256-OLD...
  got:       sha256-NEW...
```

The skill extracts `sha256-NEW...` and updates the relevant `cargoHash` or `vendorHash`.

## Instructions for Claude

When this skill is invoked:

1. Run `home-manager switch --flake ~/workbench/nixos-config/home-manager#nimalan 2>&1` and capture output

2. Look for hash mismatch errors in the format:
   - `specified: sha256-...`
   - `got:       sha256-...`

3. Identify which package has the mismatch by looking at the derivation name in the error

4. Update the appropriate hash in `~/workbench/nixos-config/home-manager/flake.nix`:
   - For `claude-tmux`: update `cargoHash`
   - For `twig`: update `vendorHash`

5. Re-run `home-manager switch` to verify the fix

6. If multiple packages need hash updates, repeat the process until all hashes are correct
