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
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, llm-agents }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      llmPkgs = llm-agents.packages.${system};
      gwqPkg = pkgs.callPackage ./nix/packages/gwq.nix { };

      mkProfile = name: hostFile:
        let
          base = {
            profileName = name;
            extraCasks = [];
            extraMasApps = {};
            extraPackages = [];
            git = { email = null; signingKey = null; };
          };
          host = import hostFile { inherit pkgs; };
        in
          base // host // { profileName = name; git = base.git // (host.git or {}); };

      mkDarwinSystem = name: hostFile:
        let profile = mkProfile name hostFile;
        in nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit llmPkgs gwqPkg profile; };
              home-manager.users.${profile.username} = import ./nix/home.nix;
            }
          ];
          specialArgs = { inherit inputs llmPkgs profile; };
        };
    in
    {
      darwinConfigurations.personal = mkDarwinSystem "personal" ./nix/hosts/personal.nix;
      darwinConfigurations.work     = mkDarwinSystem "work"     ./nix/hosts/work.nix;
    };
}
