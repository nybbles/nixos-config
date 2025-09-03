{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations = {
      framewerk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/framewerk/configuration.nix
          nixos-hardware.nixosModules.framework-13-7040-amd
          # Home Manager is now managed separately
        ];
      };
    };
  };
}
