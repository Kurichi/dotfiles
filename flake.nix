{
  description = "Kurichi's dotfiles managed by nix-darwin and home-manager";

  nixConfig = {
    extra-substituters = [
      "https://ryoppippi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-overlay = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, llm-agents, claude-code-overlay }:
    let
      username = "kurichi";
      hostname = "Kurichi-MacBook-Pro";
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      llmPkgs = llm-agents.packages.${system};
      gwqPkg = pkgs.callPackage ./nix/packages/gwq.nix { };
    in
    {
      darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./nix/darwin.nix
          { nixpkgs.overlays = [ claude-code-overlay.overlays.default ]; }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit llmPkgs gwqPkg; };
            home-manager.users.${username} = import ./nix/home.nix;
          }
        ];
        specialArgs = { inherit inputs username hostname llmPkgs; };
      };
    };
}
