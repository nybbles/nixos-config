{
  description = "Home Manager configuration for nimalan";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    themester = {
      url = "git+file:///Users/nimalan/workbench/themester";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    themester,
    ...
  } @ inputs: let
    # Support both Linux and macOS
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Detect current system
    system = builtins.currentSystem or "aarch64-darwin";
  in {
    homeConfigurations = {
      nimalan = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          (import ./home.nix {username = "nimalan"; themester = themester.packages.${system};})
        ];
      };
    };

    # Add packages output for compatibility
    packages = forAllSystems (system: {
      homeConfigurations.nimalan.activationPackage = self.homeConfigurations.nimalan.activationPackage;
    });

    # Add default package
    defaultPackage = forAllSystems (
      system:
        self.homeConfigurations.nimalan.activationPackage
    );
  };
}
