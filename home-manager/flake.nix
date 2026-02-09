{
  description = "Home Manager configuration for nimalan";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Code workflow tools
    twig = {
      url = "github:708u/twig";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    twig,
    ...
  } @ inputs: let
    # Support both Linux and macOS
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Detect current system
    system = builtins.currentSystem or "aarch64-darwin";

    # Overlay for twig package
    overlay = final: prev: {
      twig = final.buildGoModule {
        pname = "twig";
        version = "unstable";
        src = inputs.twig;
        vendorHash = "sha256-HCePabENC0wlFGXaHbvHT7jTd1yN7fzexMWez94W5kE=";
        subPackages = ["cmd/twig"];

        # Patch go.mod to use a valid Go version (1.25.5 doesn't exist)
        postPatch = ''
          substituteInPlace go.mod \
            --replace-fail "go 1.25.5" "go 1.23"
        '';

        # Skip tests that require git in build environment
        doCheck = false;
      };
    };

    # Create pkgs with overlay applied
    pkgsWithOverlay = import nixpkgs {
      inherit system;
      overlays = [overlay];
    };
  in {
    homeConfigurations = {
      nimalan = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsWithOverlay;
        modules = [
          (import ./home.nix {username = "nimalan";})
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
