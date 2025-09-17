{
  description = "Home Manager configuration for nimalan";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Support both Linux and macOS
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      homeConfigurations = forAllSystems (system: {
        nimalan = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ 
            (import ./home.nix { username = "nimalan"; })
          ];
        };
      });
      
      # Add packages output for compatibility
      packages = forAllSystems (system: {
        nimalan = self.homeConfigurations.${system}.nimalan.activationPackage;
      });
      
      # Add legacyPackages output for compatibility  
      legacyPackages = forAllSystems (system: {
        nimalan = self.homeConfigurations.${system}.nimalan.activationPackage;
      });
    };
}
