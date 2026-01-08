{
  description = "Kurichi's dotfiles managed by nix-darwin and home-manager";

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

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, llm-agents, wezterm }:
    let
      username = "kurichi";
      hostname = "Kurichi-MacBook-Pro";
      system = "aarch64-darwin";
      llmPkgs = llm-agents.packages.${system};
      weztermPkg = wezterm.packages.${system}.default;
    in
    {
      darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./nix/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit llmPkgs weztermPkg; };
            home-manager.users.${username} = import ./nix/home.nix;
          }
        ];
        specialArgs = { inherit inputs username hostname llmPkgs; };
      };
    };
}
