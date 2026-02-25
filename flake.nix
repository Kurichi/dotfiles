{
  description = "Kurichi's dotfiles managed by nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "git+ssh://git@github.com/NixOS/nixpkgs?ref=nixpkgs-unstable";

    nix-darwin = {
      url = "git+ssh://git@github.com/LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "git+ssh://git@github.com/nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "git+ssh://git@github.com/numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, llm-agents }:
    let
      username = "kurichi";
      hostname = "Kurichi-MacBook-Pro";
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      llmPkgs = llm-agents.packages.${system};
      gwqPkg = pkgs.callPackage ./nix/packages/gwq.nix { };

      mkDarwin = { username, hostname }: nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./nix/darwin.nix
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
      in
      {
        darwinConfigurations = {
          personal = mkDarwin {
            username = "kurichi";
            hostname = "kurichi-MacBook-Pro";
          };
	  ca = mkDarwin {
            username = "s30264";
            hostname = "CA-20036999";
          };
      };
    };
}
